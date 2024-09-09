exports.install = function() {

	// Misc
	ROUTE('+API    ?       -account                   --> Account/read');
	ROUTE('+API    ?       +cl                        --> Common/cl');
	ROUTE('+API    ?       -version                   --> Common/version');

	// Tickets
	ROUTE('+API    ?       -tickets                   --> Tickets/list');
	ROUTE('+API    ?       -tickets_find              --> Tickets/find');
	ROUTE('+API    ?       -tickets_calendar          --> Tickets/calendar');
	ROUTE('+API    ?       -tickets_detail/{id}       --> Tickets/read');
	ROUTE('+API    ?       -tickets_users             --> Tickets/users');
	ROUTE('+API    ?       +tickets_create            --> Tickets/create', 1024 * 10);
	ROUTE('+API    ?       +tickets_update/{id}       --> Tickets/update', 1024 * 10);
	ROUTE('+API    ?       +tickets_clone/{id}        --> Tickets/clone');
	ROUTE('+API    ?       -tickets_remove/{id}       --> Tickets/remove');
	ROUTE('+API    ?       -tickets_logs/{id}         --> Tickets/logs');
	ROUTE('+API    ?       -tickets_history/{id}      --> Tickets/history');
	ROUTE('+API    ?       +tickets_bookmarks/{id}    --> Tickets/bookmark');
	ROUTE('+API    ?       -tickets_unread            --> Tickets/unread');
	ROUTE('+API    ?       -tickets_counter           --> Tickets/counter');
	ROUTE('+API    ?       +tickets_link/{id}         --> Tickets/link');
	ROUTE('+API    ?       -tickets_links/{id}        --> Tickets/links');
	ROUTE('+API    ?       -tickets_reset/{id}        --> Tickets/reset');
	ROUTE('+API    ?       -tickets_markdown/{id}     --> Tickets/markdown');
	ROUTE('+API    ?       +logwork_create            --> Tickets/logwork_create');
	ROUTE('+API    ?       +logwork_update/{id}       --> Tickets/logwork_update');
	ROUTE('+API    ?       -logwork_remove/{id}       --> Tickets/logwork_remove');
	ROUTE('+API    ?       -logwork_open              --> Tickets/logwork_open');
	ROUTE('+API    ?       +logwork_start             --> Tickets/logwork_start');
	ROUTE('+API    ?       +logwork_stop              --> Tickets/logwork_stop');
	ROUTE('+API    ?       -comments/{id}             --> Tickets/comments');
	ROUTE('+API    ?       +comments_create           --> Tickets/comments_create');
	ROUTE('+API    ?       +comments_update/{id}      --> Tickets/comments_update');
	ROUTE('+API    ?       -comments_remove/{id}      --> Tickets/comments_remove');
	ROUTE('+API    ?       -data_read/{id}            --> Tickets/data_read');
	ROUTE('+API    ?       +data_save/{id}            --> Tickets/data_save');

	// Folders
	ROUTE('+API    ?       -folders                   --> Folders/list');
	ROUTE('+API    ?       -folders_read/{id}         --> Folders/read');
	ROUTE('+API    ?       +folders_create            --> Folders/create');
	ROUTE('+API    ?       +folders_update/{id}       --> Folders/update');
	ROUTE('+API    ?       -folders_remove/{id}       --> Folders/remove');

	// Tags
	ROUTE('+API    ?       -tags                      --> Tags/list');
	ROUTE('+API    ?       -tags_read/{id}            --> Tags/read');
	ROUTE('+API    ?       +tags_create               --> Tags/create');
	ROUTE('+API    ?       +tags_update/{id}          --> Tags/update');
	ROUTE('+API    ?       -tags_remove/{id}          --> Tags/remove');

	// Settings
	ROUTE('+API    ?       -settings_read             --> Settings/read');
	ROUTE('+API    ?       +settings_save             --> Settings/save');

	// Files
	ROUTE('+POST  /upload/ @upload <5MB', upload);
	ROUTE('FILE   /download/*.*', files);

	ROUTE('+SOCKET ?', socket);
};

function socket($) {

	var clients = {};

	MAIN.ws = $;

	$.autodestroy(() => MAIN.ws = null);

	$.on('open', function(client) {
		var msg = { TYPE: 'sync', data: clients };
		client.send(msg);
	});

	$.on('close', function(client) {
		$.send({ TYPE: 'close', data: clients[client.query.id], clientid: client.query.id });
		delete clients[client.query.id];
	});

	$.on('message', function(client, msg) {
		if (msg.TYPE === 'ticket') {
			client.ticketid = msg.id;
			clients[client.query.id] = { clientid: client.query.id, userid: client.user.id, ticketid: msg.id };
			$.send({ TYPE: 'ticket', data: clients[client.query.id], clientid: client.query.id });
		}
	});
}

async function upload($) {

	var output = [];

	for (var file of $.files) {
		var obj = {};
		obj.id = UID();
		obj.type = file.type;
		obj.size = file.size;
		obj.ext = file.ext;
		obj.url = '/download/' + obj.id.sign(CONF.salt) + '.' + obj.ext;
		obj.name = file.filename;
		obj.width = file.width;
		obj.height = file.height;
		obj.dtcreated = NOW;
		await file.fs('attachments', obj.id);
		output.push(obj);
	}

	$.json(output);

	// Write to DB
	for (var obj of output) {
		if ($.query.folderid)
			obj.folderid = $.query.folderid;
		if ($.query.ticketid)
			obj.ticketid = $.query.ticketid;
		obj.userid = $.user.id;
		obj.search = obj.name.toSearch();
		DATA.insert('tbl_file', obj);
	}
}

const Download = { jpeg: 1, jpg: 1, png: 1, gif: 1, ico: 1, webp: 1, mp4: 1, mov: 1, mpeg: 1, svg: 1, pdf: 1 };

function files($) {
	var filename = $.split[1];
	var id = filename.substring(0, filename.lastIndexOf('.'));
	var arr = id.split('-');
	if (arr[0].sign(CONF.salt) === id) {
		var download = $.query.download === '1' || Download[$.ext] !== 1;
		$.filefs('attachments', arr[0], download, null, null);
	} else
		$.invalid(404);
}