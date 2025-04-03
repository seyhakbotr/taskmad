String getStatusText(String status) {
  switch (status.toLowerCase()) {
    case 'todo':
      return 'To Do';
    case 'in_progress':
      return 'In Progress';
    case 'done':
      return 'Done';
    default:
      return 'To Do';
  }
}
