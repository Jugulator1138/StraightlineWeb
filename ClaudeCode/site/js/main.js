// main.js - Straight-Line Custom Solutions

(function() {
  'use strict';

  // Navigation toggle
  const navToggle = document.getElementById('nav-toggle');
  const navMenu = document.getElementById('nav-menu');

  if (navToggle && navMenu) {
    navToggle.addEventListener('click', () => {
      const isOpen = navToggle.getAttribute('aria-expanded') === 'true';
      navToggle.setAttribute('aria-expanded', !isOpen);
      navMenu.classList.toggle('is-open');
      document.body.style.overflow = isOpen ? '' : 'hidden';
    });

    // Close menu when clicking a link
    navMenu.querySelectorAll('.nav__link').forEach(link => {
      link.addEventListener('click', () => {
        navToggle.setAttribute('aria-expanded', 'false');
        navMenu.classList.remove('is-open');
        document.body.style.overflow = '';
      });
    });
  }

  // Hide nav on scroll down, show on scroll up
  let lastScroll = 0;
  const nav = document.getElementById('nav');

  window.addEventListener('scroll', () => {
    const currentScroll = window.pageYOffset;

    if (currentScroll <= 0) {
      nav.classList.remove('nav--hidden');
      return;
    }

    if (currentScroll > lastScroll && currentScroll > 100) {
      nav.classList.add('nav--hidden');
    } else {
      nav.classList.remove('nav--hidden');
    }

    lastScroll = currentScroll;
  }, { passive: true });

  // Project Modal
  const modal = document.getElementById('project-modal');
  const modalGallery = document.getElementById('modal-gallery');
  const modalCategory = document.getElementById('modal-category');
  const modalTitle = document.getElementById('modal-title');
  const modalDescription = document.getElementById('modal-description');
  const modalClose = modal?.querySelector('.modal__close');
  const modalBackdrop = modal?.querySelector('.modal__backdrop');
  const modalCurrent = document.getElementById('modal-current');
  const modalTotal = document.getElementById('modal-total');
  const modalPrev = modal?.querySelector('.modal__nav-btn--prev');
  const modalNext = modal?.querySelector('.modal__nav-btn--next');

  let currentImageIndex = 0;
  let currentImages = [];

  function openModal(projectCard) {
    const category = projectCard.querySelector('.project-card__category')?.textContent || '';
    const title = projectCard.querySelector('.project-card__title')?.textContent || '';
    const caption = projectCard.querySelector('.project-card__caption')?.textContent || '';

    modalCategory.textContent = category;
    modalTitle.textContent = title;
    modalDescription.textContent = caption;

    // Placeholder image for now
    currentImages = ['placeholder'];
    currentImageIndex = 0;
    updateGallery();

    modal.setAttribute('aria-hidden', 'false');
    document.body.style.overflow = 'hidden';
  }

  function closeModal() {
    modal.setAttribute('aria-hidden', 'true');
    document.body.style.overflow = '';
  }

  function updateGallery() {
    modalGallery.innerHTML = '<div class="project-card__placeholder" style="width:100%;height:300px;"></div>';
    modalCurrent.textContent = currentImageIndex + 1;
    modalTotal.textContent = currentImages.length;
  }

  function nextImage() {
    currentImageIndex = (currentImageIndex + 1) % currentImages.length;
    updateGallery();
  }

  function prevImage() {
    currentImageIndex = (currentImageIndex - 1 + currentImages.length) % currentImages.length;
    updateGallery();
  }

  // Event listeners
  document.querySelectorAll('.project-card').forEach(card => {
    card.addEventListener('click', () => openModal(card));
  });

  modalClose?.addEventListener('click', closeModal);
  modalBackdrop?.addEventListener('click', closeModal);
  modalPrev?.addEventListener('click', prevImage);
  modalNext?.addEventListener('click', nextImage);

  // Keyboard navigation
  document.addEventListener('keydown', (e) => {
    if (modal?.getAttribute('aria-hidden') === 'false') {
      if (e.key === 'Escape') closeModal();
      if (e.key === 'ArrowLeft') prevImage();
      if (e.key === 'ArrowRight') nextImage();
    }
  });

  // Image loading
  document.querySelectorAll('img').forEach(img => {
    if (img.complete) {
      img.classList.add('loaded');
    } else {
      img.addEventListener('load', () => img.classList.add('loaded'));
    }
  });

})();
