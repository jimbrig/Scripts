import "../node_modules/gridjs/dist/gridjs.umd.js";
import "../node_modules/gridjs/dist/theme/mermaid.css";

new gridjs.Grid({
    columns: [
        { id: 'name', name: 'Name' },
        { id: 'age', name: 'Age' },
        { id: 'address', name: 'Address', sort: false },
        { id: 'phone', name: 'Phone Number', sort: false },
        { id: 'email', name: 'Email' },
    ],
    server: {
        url: '/api/data',
        then: results => results.data,
    },
    search: {
        selector: (cell, rowIndex, cellIndex) => [0, 1, 4].includes(cellIndex) ? cell : null,
    },
    sort: true,
    pagination: true,
}).render(document.getElementById('table'))
