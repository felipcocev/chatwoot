/* global axios */
import ApiClient from './ApiClient';

class Kanban extends ApiClient {
  constructor() {
    super('kanban', { accountScoped: true });
  }

  getBoard() {
    return axios.get(this.url);
  }

  moveCard(cardId, kanbanColumnId, position) {
    return axios.patch(`${this.url}/cards/${cardId}/move`, {
      kanban_column_id: kanbanColumnId,
      position,
    });
  }
}

export default new Kanban();
