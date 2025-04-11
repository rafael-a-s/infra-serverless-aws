---
layout: image-right-overlay
class: 'flex flex-col justify-center'
image: '/media/backgrounds/blue.png'
---

<h1 class="font-300 no-m">Próximos passos</h1>
<h3 class="no-m">Implementações</h3>

<div class="grid grid-cols-3 gap-2 mt-6">
<v-clicks>
    <CircleIconBox>
        <template v-slot:default>
        <logos-aws-cloudwatch class="w-30px h-30px" />
        </template>
        <template v-slot:title>
        CloudWatch para monitorar
        </template>
    </CircleIconBox>
    <CircleIconBox>
        <template v-slot:default>
        <logos-gitlab class="w-30px h-30px" />
        </template>
        <template v-slot:title>
        CI/CD com GitHub Actions + Terraform Cloud ou CodePipeline
        </template>
    </CircleIconBox>
</v-clicks>
</div>