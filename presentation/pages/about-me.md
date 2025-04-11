---
layout: center
---

<h1 class="font-600 no-mb">Rafael Aguiar</h1>
<h3><em>Full stack</em></h3>

<br />


<v-clicks :every="2">
<p class="font-bold">Competências</p>

<div class="grid grid-cols-6 gap-2 w-3/5">
    <IconBox>
        <template v-slot:default>
        <logos-spring-icon class="w-30px h-30px" />
        </template>
        <template v-slot:title>
        Spring Boot
        </template>
    </IconBox>
    <IconBox>
        <template v-slot:default>
        <logos-nextjs-icon class="w-30px h-30px" />
        </template>
        <template v-slot:title>
        Nextjs
        </template>
    </IconBox>
    <IconBox>
        <template v-slot:default>
        <logos-nodejs-icon  class="w-30px h-30px" />
        </template>
        <template v-slot:title>
        NodeJS
        </template>
    </IconBox>
    <IconBox>
        <template v-slot:default>
        <logos-flutter class="w-30px h-30px" />
        </template>
        <template v-slot:title>
        Flutter
        </template>
    </IconBox>
    <IconBox>
        <template v-slot:default>
        <logos-java  class="w-30px h-30px text-logos-chakra" />
        </template>
        <template v-slot:title>
        Java
        </template>
    </IconBox>
    <IconBox>
        <template v-slot:default>
        <logos-typescript-icon  class="w-30px h-30px" />
        </template>
        <template v-slot:title>
        TypeScript
        </template>
    </IconBox>
</div>


<p class="font-bold mt-2 no-mb">Percurso Académico</p>
</v-clicks>

<div class="flex gap-2 mt-2 justify-between w-3/5">
<v-clicks>
    <AcademicBox class="text-xs"><small>Graduando</small>Bacharelado em Sistemas de Informação</AcademicBox>
</v-clicks>
</div>


<img src="/media/rafael-aguiar.png" class="rounded-full size-200px object-cover-top abs-tr mt-16 mr-12"/>