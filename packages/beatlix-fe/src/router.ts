import type {
  RouteRecordRaw,
} from 'vue-router';
import {
  createMemoryHistory, createRouter,
} from 'vue-router';
import NotFoundView from './views/not-found/NotFoundView.vue';
import SignInView from './views/auth/sign-in/SignInView.vue';
import SignUpView from './views/auth/sign-up/SignUpView.vue';
import PersonalSpaceView from './views/spaces/PersonalSpaceView.vue';

const routes: RouteRecordRaw[] = [
  // Main entry
  {
    path: '/app',
    name: 'App',
    redirect (to, from) { },
  },
  // Spaces
  {
    path: '/spaces',
    name: 'SpacesBase',
    redirect (to, from) { },
  },
  {
    path: '/spaces/@me',
    name: 'PersonalSpace',
    component: PersonalSpaceView,
  },
  // Auth
  {
    path: '/sign-in',
    name: 'Sign in',
    beforeEnter () { },
    component: SignInView,
  },
  {
    path: '/sign-up',
    name: 'Sign up',
    beforeEnter () { },
    component: SignUpView,
  },
  {
    path: '/sign-out',
    name: 'Sign out',
    beforeEnter () { },
    redirect (to, from) { },
  },
  // 404: Ensure this is at the end
  {
    path: '/:pathMatch(.*)*',
    name: 'NotFound',
    component: NotFoundView,
  },
];

export const router = createRouter({
  history: createMemoryHistory(),
  routes,
});
