/* global Swiper */
(() => {
  const swiper = new Swiper('.swiper', {
    loop: false,
    slidesPerView: 1,
    navigation: {
      nextEl: '.swiper-button-next',
      prevEl: '.swiper-button-prev',
    },
    pagination: {
      el: '.swiper-pagination',
      clickable: true,
    },
  });

  window.__swiper = swiper;
})();
