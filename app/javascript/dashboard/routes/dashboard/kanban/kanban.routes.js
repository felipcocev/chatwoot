import { frontendURL } from '../../../helper/URLHelper';
import KanbanIndex from './Index.vue';

const CONVERSATION_PERMISSIONS = [
  'administrator',
  'agent',
  'conversation_manage',
  'conversation_unassigned_manage',
  'conversation_participating_manage',
];

export const routes = [
  {
    path: frontendURL('accounts/:accountId/kanban'),
    name: 'kanban_dashboard',
    meta: {
      permissions: CONVERSATION_PERMISSIONS,
    },
    component: KanbanIndex,
  },
];
