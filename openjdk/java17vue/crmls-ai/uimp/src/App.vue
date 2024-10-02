<script setup>
import { ref } from 'vue'

const msg = ref('Hello World! Welcome to VUE')
</script>

<template>
  <h1>{{ msg }}</h1>
  <input v-model="msg" />
</template>
