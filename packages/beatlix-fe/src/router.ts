import type {
  RouteRecordRaw,
} from 'vue-router';
import {
  createMemoryHistory, createRouter,
} from 'vue-router';
import NotFoundView from './views/not-found/NotFoundView.vue';

const routes: RouteRecordRaw[] = [
  // 404: Ensure this is at the end
  {
    path: '/:pathMatch(.*)*',
    component: NotFoundView,
  },
];

export const router = createRouter({
  history: createMemoryHistory(),
  routes,
});
