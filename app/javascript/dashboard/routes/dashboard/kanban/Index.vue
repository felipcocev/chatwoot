<template>
  <div class="kanban-page">
    <div class="kanban-page__header">
      <div>
        <h1 class="kanban-page__title">{{ board?.name || 'Kanban' }}</h1>
        <p class="kanban-page__subtitle">
          Gerencie conversas em colunas e mova cards entre etapas.
        </p>
      </div>
      <button class="button button--secondary" @click="loadBoard" :disabled="isLoading">
        {{ isLoading ? 'Carregando...' : 'Atualizar' }}
      </button>
    </div>

    <div v-if="isLoading && !board" class="kanban-page__empty">
      Carregando kanban...
    </div>

    <div v-else-if="hasError" class="kanban-page__empty">
      Não foi possível carregar o kanban.
    </div>

    <div v-else class="kanban-board">
      <div
        v-for="column in columns"
        :key="column.id"
        class="kanban-column"
        @dragover.prevent
        @drop="onDrop(column.id, column.cards.length)"
      >
        <div class="kanban-column__header">
          <h2>{{ column.name }}</h2>
          <span>{{ column.cards.length }}</span>
        </div>

        <div class="kanban-column__body">
          <div
            v-for="(card, cardIndex) in column.cards"
            :key="card.id"
            class="kanban-card"
            draggable="true"
            @dragstart="onDragStart(card, column.id, cardIndex)"
            @dragover.prevent
            @drop.stop="onDrop(column.id, cardIndex)"
          >
            <div class="kanban-card__top">
              <strong>#{{ card.display_id }}</strong>
              <span>{{ card.status }}</span>
            </div>

            <div class="kanban-card__name">
              {{ card.contact?.name || 'Sem nome' }}
            </div>

            <div class="kanban-card__meta">
              <div>{{ card.contact?.email || 'Sem email' }}</div>
              <div>Inbox: {{ card.inbox_id }}</div>
            </div>
          </div>

          <div v-if="!column.cards.length" class="kanban-column__empty">
            Nenhum card nesta coluna
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import KanbanAPI from 'dashboard/api/kanban';

export default {
  name: 'KanbanIndex',
  data() {
    return {
      board: null,
      isLoading: false,
      hasError: false,
      draggingCard: null,
    };
  },
  computed: {
    columns() {
      return this.board?.columns || [];
    },
  },
  mounted() {
    this.loadBoard();
  },
  methods: {
    async loadBoard() {
      this.isLoading = true;
      this.hasError = false;

      try {
        const response = await KanbanAPI.getBoard();
        const payload = response?.data;
        this.board = Array.isArray(payload) ? payload[0] : payload;
      } catch (error) {
        this.hasError = true;
      } finally {
        this.isLoading = false;
      }
    },

    onDragStart(card, sourceColumnId, sourceIndex) {
      this.draggingCard = {
        ...card,
        sourceColumnId,
        sourceIndex,
      };
    },

    async onDrop(targetColumnId, targetIndex) {
      if (!this.draggingCard) return;

      const { id } = this.draggingCard;

      try {
        const response = await KanbanAPI.moveCard(id, targetColumnId, targetIndex);
        const payload = response?.data;
        this.board = Array.isArray(payload) ? payload[0] : payload;
      } catch (error) {
        await this.loadBoard();
      } finally {
        this.draggingCard = null;
      }
    },
  },
};
</script>

<style scoped>
.kanban-page {
  padding: 24px;
  height: 100%;
  overflow: hidden;
}

.kanban-page__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 20px;
}

.kanban-page__title {
  margin: 0;
  font-size: 24px;
  font-weight: 700;
}

.kanban-page__subtitle {
  margin: 4px 0 0;
  color: #6b7280;
}

.kanban-page__empty {
  padding: 40px;
  border: 1px dashed #d1d5db;
  border-radius: 12px;
  background: #fff;
}

.kanban-board {
  display: flex;
  gap: 16px;
  height: calc(100vh - 180px);
  overflow-x: auto;
  align-items: flex-start;
}

.kanban-column {
  min-width: 320px;
  max-width: 320px;
  background: #f9fafb;
  border: 1px solid #e5e7eb;
  border-radius: 14px;
  display: flex;
  flex-direction: column;
  max-height: 100%;
}

.kanban-column__header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 14px 16px;
  border-bottom: 1px solid #e5e7eb;
}

.kanban-column__header h2 {
  margin: 0;
  font-size: 16px;
  font-weight: 700;
}

.kanban-column__header span {
  background: #e5e7eb;
  border-radius: 999px;
  padding: 4px 10px;
  font-size: 12px;
  font-weight: 600;
}

.kanban-column__body {
  padding: 12px;
  overflow-y: auto;
  min-height: 140px;
}

.kanban-column__empty {
  color: #9ca3af;
  padding: 16px;
  text-align: center;
  border: 1px dashed #d1d5db;
  border-radius: 10px;
  background: #fff;
}

.kanban-card {
  background: #fff;
  border: 1px solid #e5e7eb;
  border-radius: 12px;
  padding: 12px;
  margin-bottom: 12px;
  cursor: grab;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.04);
}

.kanban-card:last-child {
  margin-bottom: 0;
}

.kanban-card__top {
  display: flex;
  justify-content: space-between;
  gap: 8px;
  margin-bottom: 10px;
  font-size: 12px;
  color: #6b7280;
}

.kanban-card__name {
  font-size: 15px;
  font-weight: 700;
  margin-bottom: 8px;
}

.kanban-card__meta {
  font-size: 12px;
  color: #6b7280;
  display: grid;
  gap: 4px;
}
</style>
