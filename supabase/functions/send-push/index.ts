import { serve } from 'https://deno.land/std@0.224.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { cert, getApps, initializeApp } from 'npm:firebase-admin/app'
import { getMessaging } from 'npm:firebase-admin/messaging'

type PushInput = { conversationId: string; messageId: string; mention?: boolean }

// Service-account JSON is read only from the Edge Function Secret
// FIREBASE_SERVICE_ACCOUNT_JSON. It never reaches the mobile client.
serve(async (request) => {
  if (request.method !== 'POST') return new Response('Method not allowed', { status: 405 })
  const authorization = request.headers.get('Authorization')
  if (authorization == null || !authorization.startsWith('Bearer ')) {
    return Response.json({ error: 'unauthorized' }, { status: 401 })
  }
  try {
    const url = Deno.env.get('SUPABASE_URL')!
    const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!
    const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const requester = createClient(url, anonKey, { global: { headers: { Authorization: authorization } } })
    const { data: userData, error: userError } = await requester.auth.getUser()
    if (userError != null || userData.user == null) return Response.json({ error: 'unauthorized' }, { status: 401 })
    const input = await request.json() as PushInput
    if (!input.conversationId || !input.messageId) return Response.json({ error: 'invalid request' }, { status: 400 })
    // RLS first ensures membership; ownership prevents arbitrary push fan-out.
    const { data: message, error: messageError } = await requester.from('messages').select('id, conversation_id, sender_id, body, deleted_at').eq('id', input.messageId).single()
    if (messageError != null || message == null || message.conversation_id !== input.conversationId || message.sender_id !== userData.user.id || message.deleted_at != null) {
      return Response.json({ error: 'forbidden' }, { status: 403 })
    }
    const admin = createClient(url, serviceKey)
    const { data: sender } = await admin.from('profiles').select('display_name').eq('id', userData.user.id).single()
    const { data: members, error: membersError } = await admin.from('conversation_members').select('user_id').eq('conversation_id', input.conversationId).is('left_at', null).neq('user_id', userData.user.id)
    if (membersError != null) return Response.json({ error: 'membership lookup failed' }, { status: 500 })
    const recipientIds = (members ?? []).map((member) => member.user_id)
    if (recipientIds.isEmpty) return Response.json({ delivered: 0 })
    const { data: tokens } = await admin.from('device_tokens').select('token').in('user_id', recipientIds)
    const registrationTokens = (tokens ?? []).map((token) => token.token)
    if (registrationTokens.isEmpty) return Response.json({ delivered: 0 })
    const credential = Deno.env.get('FIREBASE_SERVICE_ACCOUNT_JSON')
    if (!credential) return Response.json({ error: 'push delivery unavailable' }, { status: 503 })
    if (!getApps().length) initializeApp({ credential: cert(JSON.parse(credential)) })
    const result = await getMessaging().sendEachForMulticast({
      tokens: registrationTokens,
      notification: { title: sender?.display_name ?? 'New message', body: message.body || 'Sent an attachment' },
      data: { conversationId: input.conversationId, messageId: input.messageId, mention: input.mention ? 'true' : 'false' },
      android: { priority: 'high' }, apns: { payload: { aps: { sound: 'default' } } },
    })
    return Response.json({ delivered: result.successCount, failed: result.failureCount })
  } catch (error) {
    console.error('send-push failed', error)
    return Response.json({ error: 'push delivery failed' }, { status: 500 })
  }
})
