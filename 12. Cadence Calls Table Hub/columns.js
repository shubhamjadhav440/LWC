const columns = [
  {
    label: 'Name',
    type: 'nameColumn',
    fieldName: 'name',
    sortable: true,
    fixedWidth: 350,
    typeAttributes: {
      name: {fieldName: 'name'},
      id: {fieldName: 'id'},
    },
    cellAttributes: { alignment: 'left' }
  },
  {
    label: 'Date',
    fieldName: 'callDate',
    type: 'date',
    sortable: true,
    typeAttributes:{
      month: "short",
      day: "2-digit",
      year: "numeric",
      hour: "2-digit",
      minute: "2-digit"
    },
    cellAttributes: { alignment: 'left' },
  },
  {
    label: 'SAE Owner',
    fieldName: 'owner',
    type: 'string',
    sortable: true,
    cellAttributes: { alignment: 'left' },
  }
];

export { columns };