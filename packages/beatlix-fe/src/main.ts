import {
  createApp,
} from 'vue';
import {
  createPinia,
} from 'pinia';
import App from './App.vue';
import {
  router,
} from './router';

const app = createApp(App); // Create the app

// Plugins
const pinia = createPinia();

app.use(router);
app.use(pinia);

// Mount the app
app.mount('#app');
