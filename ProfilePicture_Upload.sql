CREATE TABLE project.profile_pictures (
    f varchar(20) NOT NULL,
    fb bytea NOT NULL,
	id bigint NOT NULL
);
ALTER TABLE IF EXISTS project.profile_pictures OWNER to zdeng;

INSERT INTO project.profile_pictures (f, fb, id)
SELECT f, pg_read_binary_file('/sftp/lhsu/upload/zdeng/' || f) AS fb, u.user_id AS id
FROM pg_ls_dir('/sftp/lhsu/upload/zdeng/') AS f
JOIN project.users u
ON f = u.user_photo;

-- Technical stats of the pictures
SELECT x.f, ST_Width(r.rast), ST_Height(r.rast), ST_NumBands(r.rast), ss.*
FROM project.leo_pictures x CROSS JOIN LATERAL ST_FromGDALRaster(x.fb) AS r(rast) CROSS JOIN LATERAL ST_SummaryStats(r.rast) AS ss;

-- "Simplify" pictures so they could be viewed in PGAdmin. Click on the flag icon to view.
SELECT f, ST_Polygon(reclass_rast)
FROM
	(SELECT * FROM project.leo_pictures WHERE f = 'Photo2.jpeg') AS d CROSS JOIN LATERAL
	ST_FromGDALRaster(d.fb) AS rast CROSS JOIN LATERAL
	ST_Reclass(rast,1,'0-10:0,20-150: 20, 151-255: 0','8BUI',0) AS reclass_rast
;