// functions/submit-form.js - Cloudflare Pages Function

export async function onRequestPost(context) {
  try {
    const formData = await context.request.json();

    // Validate honeypot
    if (formData.website) {
      return new Response(JSON.stringify({ error: 'Invalid submission' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      });
    }

    // Validate required fields
    if (!formData.name || !formData.email || !formData.message) {
      return new Response(JSON.stringify({ error: 'Missing required fields' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      });
    }

    // Log submission (in production, send to email service or database)
    console.log('Form submission:', {
      name: formData.name,
      email: formData.email,
      message: formData.message,
      source: formData.source,
      timestamp: formData.timestamp
    });

    // TODO: Integrate with email service (Mailgun, SendGrid, etc.)
    // TODO: Store in KV or D1 database

    return new Response(JSON.stringify({ success: true }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    });

  } catch (error) {
    return new Response(JSON.stringify({ error: 'Server error' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    });
  }
}
