function (users) {
    new gridjs.Grid({
        columns: [
            { id: 'name', name: 'Name' },
            { id: 'age', name: 'Age' },
            { id: 'address', name: 'Address', sort: false },
            { id: 'phone', name: 'Phone Number', sort: false },
            { id: 'email', name: 'Email' },
        ],
        data: users,
        search: {
            selector: (cell, rowIndex, cellIndex) => [0, 1, 4].includes(cellIndex) ? cell : null,
        },
        sort: true,
        pagination: true,
    }).render(document.getElementById('table'));
}

