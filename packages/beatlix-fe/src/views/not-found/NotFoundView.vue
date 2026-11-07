<script setup lang="ts">
import {
  useRoute,
} from 'vue-router';

const {
  pathMatch,
} = useRoute().params;
</script>

<template>
  <div>{{ pathMatch }} not found :(</div>
</template>
