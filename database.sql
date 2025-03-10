BEGIN;

CREATE TABLE "public"."cl_config" (
	"id" text NOT NULL,
	"value" text,
	"type" text,
	"dtupdated" timestamp DEFAULT timezone('utc'::text, now()),
	PRIMARY KEY ("id")
);

CREATE TABLE "public"."cl_status" (
	"id" text NOT NULL,
	"name" text,
	"icon" text,
	"color" text,
	"sortindex" int2 DEFAULT 0,
	PRIMARY KEY ("id")
);

CREATE TABLE "public"."cl_notification" (
	"id" text NOT NULL,
	"name" text,
	"icon" text,
	"color" text,
	PRIMARY KEY ("id")
);

CREATE TABLE "public"."tbl_user" (
	"id" text NOT NULL,
	"photo" text,
	"name" text,
	"nick" text,
	"email" text,
	"search" text,
	"language" text,
	"reference" text,
	"token" text,
	"password" text,
	"permissions" _text,
	"notifyurl" text,
	"sa" bool DEFAULT false,
	"notifications" bool DEFAULT true,
	"isinactive" bool DEFAULT false,
	"isdisabled" bool DEFAULT false,
	"isonline" bool DEFAULT false,
	"isremoved" bool DEFAULT false,
	"dtlogged" timestamp,
	"dtupdated" timestamp,
	"dtcreated" timestamp DEFAULT timezone('utc'::text, now()),
	PRIMARY KEY ("id")
);

CREATE TABLE "public"."tbl_folder" (
	"id" text NOT NULL,
	"parentid" text,
	"name" text,
	"reference" text,
	"icon" text,
	"color" text,
	"email" text,
	"phone" text,
	"customer" text,
	"sortindex" int2 DEFAULT 0,
	"ispinned" bool DEFAULT false,
	"isprivate" bool DEFAULT false,
	"isarchived" bool DEFAULT false,
	"isbillable" bool DEFAULT false,
	"isdisabled" bool DEFAULT false,
	"dtticket" timestamp,
	"dtupdated" timestamp,
	"dtcreated" timestamp DEFAULT timezone('utc'::text, now()),
	CONSTRAINT "tbl_folder_parentid_fkey" FOREIGN KEY ("parentid") REFERENCES "public"."tbl_folder"("id") ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY ("id")
);

CREATE TABLE "public"."tbl_tag" (
	"id" text NOT NULL,
	"folderid" text,
	"name" text,
	"search" text,
	"color" text,
	"icon" text,
	"sortindex" int2 DEFAULT 0,
	"dtupdated" timestamp,
	"dtcreated" timestamp DEFAULT timezone('utc'::text, now()),
	CONSTRAINT "tbl_tag_folderid_fkey" FOREIGN KEY ("folderid") REFERENCES "public"."tbl_folder"("id") ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY ("id")
);

CREATE TABLE "public"."tbl_ticket" (
	"id" text NOT NULL,
	"folderid" text,
	"statusid" text,
	"parentid" text,
	"ownerid" text,
	"typeid" text,
	"userid" _text,
	"watcherid" _text,
	"source" text,
	"reference" text,
	"changed" text,
	"name" text,
	"search" text,
	"html" text,
	"markdown" text,
	"attachments" json,
	"attrs" json,
	"note" text,
	"callback" text,
	"tags" _text,
	"comments" int2 DEFAULT 0,
	"worked" int4 DEFAULT 0,
	"estimate" int4 DEFAULT 0,
	"ispublic" bool DEFAULT false,
	"isbillable" bool DEFAULT true,
	"ispriority" int2 DEFAULT 0,
	"isprocessed" bool DEFAULT false,
	"isremoved" bool DEFAULT false,
	"date" timestamp,
	"dtparent" timestamp,
	"deadline" timestamp,
	"dtstatus" timestamp,
	"dtupdated" timestamp,
	"dtprocessed" timestamp,
	"dtremoved" timestamp,
	"dtcreated" timestamp DEFAULT timezone('utc'::text, now()),
	CONSTRAINT "tbl_ticket_parentid_fkey" FOREIGN KEY ("parentid") REFERENCES "public"."tbl_ticket"("id") ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT "tbl_ticket_ownerid_fkey" FOREIGN KEY ("ownerid") REFERENCES "public"."tbl_user"("id") ON DELETE SET NULL ON UPDATE CASCADE,
	CONSTRAINT "tbl_ticket_statusid_fkey" FOREIGN KEY ("statusid") REFERENCES "public"."cl_status"("id") ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT "tbl_ticket_projectid_fkey" FOREIGN KEY ("folderid") REFERENCES "public"."tbl_folder"("id") ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY ("id")
);

CREATE TABLE "public"."tbl_ticket_bookmark" (
	"id" text NOT NULL,
	"ticketid" text,
	"userid" text,
	CONSTRAINT "tbl_ticket_bookmark_userid_fkey" FOREIGN KEY ("userid") REFERENCES "public"."tbl_user"("id") ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT "tbl_ticket_bookmark_ticketid_fkey" FOREIGN KEY ("ticketid") REFERENCES "public"."tbl_ticket"("id") ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY ("id")
);

CREATE TABLE "public"."tbl_ticket_comment" (
	"id" text NOT NULL,
	"ticketid" text,
	"userid" text,
	"username" text,
	"userphoto" text,
	"line" int4,
	"markdown" text,
	"dtcreated" timestamp DEFAULT timezone('utc'::text, now()),
	"dtupdated" timestamp,
	CONSTRAINT "tbl_ticket_comment_ticketid_fkey" FOREIGN KEY ("ticketid") REFERENCES "public"."tbl_ticket"("id") ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT "tbl_ticket_comment_userid_fkey" FOREIGN KEY ("userid") REFERENCES "public"."tbl_user"("id") ON DELETE SET NULL ON UPDATE CASCADE,
	PRIMARY KEY ("id")
);

CREATE TABLE "public"."tbl_ticket_data" (
	"id" text NOT NULL,
	"ticketid" text NOT NULL,
	"widget" text,
	"config" json,
	"sortindex" int2,
	"dtupdated" timestamp DEFAULT timezone('utc'::text, now()),
	CONSTRAINT "tbl_ticket_data_ticketid_fkey" FOREIGN KEY ("ticketid") REFERENCES "public"."tbl_ticket"("id") ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY ("id")
);

CREATE TABLE "public"."tbl_notification" (
	"id" text NOT NULL,
	"ticketid" text,
	"userid" text,
	"typeid" text,
	"createdby" text,
	"reference" text,
	"value" text,
	"isprocessed" bool DEFAULT false,
	"dtcreated" timestamp DEFAULT timezone('utc'::text, now()),
	CONSTRAINT "tbl_notification_ticketid_fkey" FOREIGN KEY ("ticketid") REFERENCES "public"."tbl_ticket"("id") ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT "tbl_notification_userid_fkey" FOREIGN KEY ("userid") REFERENCES "public"."tbl_user"("id") ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT "tbl_notification_typeid_fkey" FOREIGN KEY ("typeid") REFERENCES "public"."cl_notification"("id") ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY ("id")
);

CREATE TABLE "public"."tbl_ticket_time" (
	"id" text NOT NULL,
	"ticketid" text,
	"userid" text,
	"minutes" int4 DEFAULT 0,
	"name" text,
	"date" timestamp,
	"start" timestamp,
	"dtcreated" timestamp DEFAULT timezone('utc'::text, now()),
	CONSTRAINT "tbl_ticket_time_userid_fkey" FOREIGN KEY ("userid") REFERENCES "public"."tbl_user"("id") ON DELETE SET NULL ON UPDATE CASCADE,
	CONSTRAINT "tbl_ticket_time_ticketid_fkey" FOREIGN KEY ("ticketid") REFERENCES "public"."tbl_ticket"("id") ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY ("id")
);

CREATE TABLE "public"."tbl_ticket_unread" (
	"id" text NOT NULL,
	"ticketid" text,
	"userid" text,
	"notificationid" text,
	"iscomment" bool DEFAULT false,
	"isunread" bool DEFAULT true,
	"isprocessed" bool DEFAULT false,
	"dtupdated" timestamp,
	CONSTRAINT "tbl_ticket_unread_ticketid_fkey" FOREIGN KEY ("ticketid") REFERENCES "public"."tbl_ticket"("id") ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT "tbl_ticket_unread_userid_fkey" FOREIGN KEY ("userid") REFERENCES "public"."tbl_user"("id") ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT "tbl_ticket_unread_notificationid_fkey" FOREIGN KEY ("notificationid") REFERENCES "public"."tbl_notification"("id") ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY ("id")
);

CREATE TABLE "public"."tbl_file" (
	"id" text NOT NULL,
	"ticketid" text,
	"folderid" text,
	"userid" text,
	"name" text,
	"search" text,
	"ext" text,
	"url" text,
	"type" text,
	"width" int2 DEFAULT 0,
	"height" int2 DEFAULT 0,
	"size" int4 DEFAULT 0,
	"isremoved" bool DEFAULT false,
	"dtcreated" timestamp DEFAULT timezone('utc'::text, now()),
	CONSTRAINT "tbl_file_ticketid_fkey" FOREIGN KEY ("ticketid") REFERENCES "public"."tbl_ticket"("id") ON DELETE SET NULL ON UPDATE CASCADE,
	CONSTRAINT "tbl_file_folderid_fkey" FOREIGN KEY ("folderid") REFERENCES "public"."tbl_folder"("id") ON DELETE SET NULL ON UPDATE CASCADE,
	CONSTRAINT "tbl_file_userid_fkey" FOREIGN KEY ("userid") REFERENCES "public"."tbl_user"("id") ON DELETE SET NULL ON UPDATE CASCADE,
	PRIMARY KEY ("id")
);

CREATE TABLE "public"."tbl_session" (
	"id" text NOT NULL,
	"userid" text,
	"ua" text,
	"ip" text,
	"device" text,
	"logged" int4 DEFAULT 0,
	"isreset" bool DEFAULT false,
	"isonline" bool DEFAULT false,
	"dtexpire" timestamp,
	"dtlogged" timestamp,
	"dtcreated" timestamp DEFAULT timezone('utc'::text, now()),
	CONSTRAINT "tbl_session_userid_fkey" FOREIGN KEY ("userid") REFERENCES "public"."tbl_user"("id") ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY ("id")
);

CREATE TABLE "public"."tbl_ticket_backup" (
	"id" text NOT NULL,
	"ticketid" text,
	"userid" text,
	"markdown" text,
	"ip" text,
	"ua" text,
	"dtcreated" timestamp DEFAULT timezone('utc'::text, now()),
	CONSTRAINT "tbl_ticket_backup_ticketid_fkey" FOREIGN KEY ("ticketid") REFERENCES "public"."tbl_ticket"("id") ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT "tbl_ticket_backup_userid_fkey" FOREIGN KEY ("userid") REFERENCES "public"."tbl_user"("id") ON DELETE SET NULL ON UPDATE CASCADE,
	PRIMARY KEY ("id")
);

CREATE VIEW view_ticket AS
	SELECT
		a.id,
		a.folderid,
		a.ownerid,
		a.statusid,
		a.parentid,
		a.userid,
		a.watcherid,
		a.name,
		a.worked,
		a.estimate,
		a.comments,
		a.ispriority,
		b.name AS folder,
		b.color AS folder_color,
		b.icon AS folder_icon,
		a.attachments,
		a.tags,
		a.date,
		a.dtstatus,
		a.dtupdated,
		a.deadline,
		a.isbillable,
		d.name AS status,
		d.sortindex,
		d.icon AS status_icon,
		d.color AS status_color,
		a.search,
		b.isprivate,
		a.html,
		a.dtparent,
		a.dtcreated,
		a.reference,
		a.source,
		a.markdown,
		a.ispublic,
		a.note,
		a.attrs
	FROM tbl_ticket a
	LEFT JOIN tbl_folder b ON b.id = a.folderid
	LEFT JOIN cl_status d ON d.id = a.statusid
	WHERE
		a.isremoved = false;

CREATE VIEW view_ticket_time AS
	SELECT
		a.id,
		a.userid,
		a.ticketid,
		b.folderid,
		a.name,
		a.dtcreated,
		a.minutes,
		a.date,
		b."name" as ticket_name,
		c.name AS user_name,
		b.isbillable,
		a.start
	FROM tbl_ticket_time a
		JOIN tbl_ticket b ON b.id = a.ticketid AND b.isremoved = false
		LEFT JOIN tbl_user c ON c.id = a.userid;

-- DATA

INSERT INTO "public"."cl_notification" ("id", "name", "icon", "color") VALUES
	('comment', 'Comment', 'ti ti-comment', '#5599F8'),
	('content', 'Changed content', 'ti ti-layout', '#7327F5'),
	('logwork', 'Logged work', 'ti ti-stopwatch', '#3B80F7'),
	('metadata', 'Changed metadata', 'ti ti-invoice', '#83C83C'),
	('status', 'Changed status', 'ti ti-traffic-light', '#62C9CA'),
	('user', 'Assigned user', 'ti ti-check-circle', '#83C83C');

INSERT INTO "public"."cl_status" ("id", "name", "icon", "color", "sortindex") VALUES
	('closed', 'Closed', 'ti ti-check-circle', '#C0C0C0', 6),
	('note', 'Note', 'ti ti-book-open', '#62C9CA', 5),
	('open', 'In progress', 'ti ti-spinner', '#4285F4', 1),
	('pending', 'Pending', 'ti ti-hourglass', '#EA71B0', 2),
	('postponed', 'Postponed', 'ti ti-history', '#8C42F6', 4),
	('review', 'Review', 'ti ti-clean', '#EC8632', 3);

INSERT INTO "public"."tbl_user" ("id", "name", "search", "email", "password", "permissions", "sa", "dtcreated") VALUES
	('{id}', 'John Connor', 'johnconor', 'info@totaljs.com', '{password}', '{}', 't', timezone('utc'::text, now()));

-- INDEXES

CREATE INDEX "tbl_ticket_idxstatus" ON "public"."tbl_ticket" USING BTREE ("statusid", "folderid", "userid");
CREATE INDEX "tbl_ticket_idxparent" ON "public"."tbl_ticket" USING BTREE ("parentid");
CREATE INDEX "tbl_ticket_data_idx" ON "public"."tbl_ticket_data" USING BTREE ("ticketid");
CREATE INDEX "tbl_ticket_time_idxuser" ON "public"."tbl_ticket_time" USING BTREE ("userid", "start");
CREATE INDEX "tbl_ticket_time_idxticket" ON "public"."tbl_ticket_time" USING BTREE ("ticketid");
CREATE INDEX "tbl_ticket_unread_idxuserid" ON "public"."tbl_ticket_unread" USING BTREE ("userid", "isunread");
CREATE INDEX "tbl_ticket_comment_idxticket" ON "public"."tbl_ticket_comment" USING BTREE ("ticketid");
CREATE INDEX "tbl_notification_idxticket" ON "public"."tbl_notification" USING BTREE ("ticketid", "userid");


-- =============================================
-- DATA
-- =============================================

INSERT INTO "public"."cl_config" ("id", "value", "type") VALUES
	('allow_tms', 'false', 'boolean'),
	('cdn', '//cdn.componentator.com', 'string'),
	('name', 'Todomator', 'string'),
	('token', '', 'string'),
	('language', 'eu', 'string'),
	('minlogtime', '10', 'number'),
	('auth_cookie_expire', '1 month', 'string'),
	('auth_secret', '{secret}', 'string'),
	('auth_cookie', SUBSTRING(MD5(RANDOM()::text), 0, 5), 'string'),
	('salt', SUBSTRING(MD5(RANDOM()::text), 0, 13), 'string');

COMMIT;