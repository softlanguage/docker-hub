<script setup>
import { ref } from 'vue'

const msg = ref('Hello World! Welcome to PC by your Laptop')
</script>

<template>
  <h1>{{ msg }}</h1>
  <input v-model="msg" />
</template>
