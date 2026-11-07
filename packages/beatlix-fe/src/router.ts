import type {
  RouteRecordRaw,
} from 'vue-router';
import {
  createMemoryHistory, createRouter,
} from 'vue-router';

const routes: RouteRecordRaw[] = [];

export const router = createRouter({
  history: createMemoryHistory(),
  routes,
});
