import KanbanIndex from '../../../views/kanban/Index.vue';

export const routes = [
  {
    path: 'kanban',
    name: 'kanban_dashboard',
    roles: ['administrator', 'agent'],
    component: KanbanIndex,
  },
];
