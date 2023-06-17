const updateUrl = (prev, query) => {
    return prev + (prev.indexOf('?') >= 0 ? '&' : '?') + new URLSearchParams(query).toString();
};

new gridjs.Grid({
    columns: [
        { id: 'name', name: 'Name' },
        { id: 'age', name: 'Age' },
        { id: 'address', name: 'Address', sort: false },
        { id: 'phone', name: 'Phone Number', sort: false },
        {
            id: 'email', name: 'Email', formatter: (cell, row) => {
                return gridjs.html('<a href="mailto:' + cell + '">' + cell + '</a>');
            }
        },
    ],
    server: {
        url: '/api/data',
        then: results => results.data,
        total: results => results.total,
    },
    search: {
        enabled: true,
        server: {
            url: (prev, search) => {
                return updateUrl(prev, { search });
            },
        },
    },
    sort: {
        enabled: true,
        multiColumn: true,
        server: {
            url: (prev, columns) => {
                const columnIds = ['name', 'age', 'address', 'phone', 'email'];
                const sort = columns.map(col => (col.direction === 1 ? '+' : '-') + columnIds[col.index]);
                return updateUrl(prev, { sort });
            },
        },
    },
    pagination: {
        enabled: true,
        server: {
            url: (prev, page, limit) => {
                return updateUrl(prev, { start: page * limit, length: limit });
            },
        },
    },
}).render(document.getElementById('table'));
