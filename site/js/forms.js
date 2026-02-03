// forms.js - Form handling for Straight-Line Custom Solutions

(function() {
  'use strict';

  const contactForm = document.getElementById('contact-form');

  if (contactForm) {
    contactForm.addEventListener('submit', async (e) => {
      e.preventDefault();

      const formData = new FormData(contactForm);

      // Check honeypot
      if (formData.get('website')) {
        console.log('Bot detected');
        return;
      }

      const data = {
        name: formData.get('name'),
        email: formData.get('email'),
        message: formData.get('message'),
        source: 'contact',
        timestamp: new Date().toISOString()
      };

      const submitBtn = contactForm.querySelector('button[type="submit"]');
      const originalText = submitBtn.textContent;
      submitBtn.textContent = 'Sending...';
      submitBtn.disabled = true;

      try {
        const response = await fetch('/submit-form', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(data)
        });

        if (response.ok) {
          submitBtn.textContent = 'Sent!';
          contactForm.reset();
        } else {
          throw new Error('Submission failed');
        }

        setTimeout(() => {
          submitBtn.textContent = originalText;
          submitBtn.disabled = false;
        }, 2000);

      } catch (error) {
        console.error('Form error:', error);
        submitBtn.textContent = 'Error - Try Again';
        setTimeout(() => {
          submitBtn.textContent = originalText;
          submitBtn.disabled = false;
        }, 2000);
      }
    });
  }

})();
