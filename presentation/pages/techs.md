---
layout: center
---

<h1 class="no-mb font-300">Tecnologias & Ferramentas</h1>
<h3 class="font-xs">Tecnologias, Ferramentas e Dependências utilizadas no projeto</h3>

<br />

<v-clicks :every="2">

<p class="font-bold text-sm">Tecnologias</p>

<div class="grid grid-cols-7 gap-2 w-600px">
    <IconBox>
        <template v-slot:default>
        <logos-javascript class="w-30px h-30px" />
        </template>
        <template v-slot:title>
        Javascript
        </template>
    </IconBox>
    <IconBox>
        <template v-slot:default>
        <logos-nodejs-icon class="w-30px h-30px" />
        </template>
        <template v-slot:title>
        Node.js
        </template>
    </IconBox>
    <IconBox>
        <template v-slot:default>
        <logos-docker-icon class="w-30px h-30px" />
        </template>
        <template v-slot:title>
        Docker
        </template>
    </IconBox>
    <IconBox>
        <template v-slot:default>
        <logos-terraform-icon class="w-30px h-30px" />
        </template>
        <template v-slot:title>
        Terraform
        </template>
    </IconBox>
    <IconBox>
        <template v-slot:default>
        <logos-aws class="w-30px h-30px" />
        </template>
        <template v-slot:title>
        Stacks AWS
        </template>
    </IconBox>
</div>


<p class="font-bold text-sm">Ferramentas</p>

<div class="grid grid-cols-4 gap-2 w-1/2">
    <IconBox>
        <template v-slot:default>
        <logos-visual-studio-code class="w-30px h-30px" />
        </template>
        <template v-slot:title>
        Visual Studio Code
        </template>
    </IconBox>
    <IconBox>
        <template v-slot:default>
        <logos-npm class="w-30px h-30px" />
        </template>
        <template v-slot:title>
        Npm
        </template>
    </IconBox>
</div>


<p class="font-bold text-sm pt-4">Dependências</p>

<div class="grid grid-cols-4 gap-2 w-1/2">
    <IconBox>
        <template v-slot:default>
        <logos-aws class="w-30px h-30px" />
        </template>
        <template v-slot:title>
        AWS
        </template>
    </IconBox>
</div>

</v-clicks>