---
#==> Theme
theme: ./theme
# theme: 'default'
# colorSchema: light

#==> Layout
layout: cover
class: bg-blend-overlay bg-black65
background: '/media/backgrounds/unitinswide.png'

#==> Fonts
fonts:
  # Normal Font
  sans: 'Poppins'
  # Serif Font
  serif: 'Playfair Display'
  # Code Font
  mono: 'Fira Code'
  # Provider
  provider: 'google'

#==> Code Highlighter
highlighter: shiki

#==> Slide Info
title: Estágio Supervisionado
info: |
  ## Slidev Starter Template
  Presentation slides for developers.

  Learn more at [Sli.dev](https://sli.dev)
---
<div class="abs-tl top-5 left-5 mb-4">
  <a
    href="https://www.unitins.br/nPortal/"
    target="_blank"
    class="
      opacity-50
      !hover:opacity-100
      no-border no-decoration
      shadow-none
    "
  >
    <img
      src="/media/logos/unitins.png"
      class="w-75px"
      alt="P.Porto"
    />
  </a>
</div>

<div class="center">
  	<h1 class="font-extrabold" style="line-height: 2rem !important;">AWS + TERRAFORM</h1>
  	<h3 class="font-300" style="opacity: 1;font-size: 12px">Servidor de Aplicações Serverless com AWS Lambda e Docker</h3>
</div>

<div class="abs-bl ml-14 mb-12 flex items-center" >
	<img src="/media/rafael-aguiar.png" class="size-40px br-50p  object-cover-top no-decoration">
	<div class="ml-3 flex flex-col text-left">
		<span class="font-300">Rafael Aguiar</span>
		<span class="mt-1 fs-10px">10ª</span>
	</div>
</div>

<div class="abs-br mr-6 mb-12">
    <span
      @click="$slidev.nav.next"
      class="arrow-container cursor-pointer text-white"
      hover="bg-altBlue bg-opacity-75 text-white"
    >
      <carbon:chevron-right class="inline" />
    </span>
</div>

---
src: ./pages/about-me.md
---

---
src: ./pages/structure.md
---

---
src: ./pages/architecture.md
---

---
src: ./pages/techs.md
---

---
src: ./pages/terraform.md
---

---
src: ./pages/button.md
---

---
src: ./pages/future-work.md
---