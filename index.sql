CREATE INDEX ix_membership_package_name ON project.membership (package_name);

CREATE INDEX ix_membership_user_id ON project.membership (user_id);

CREATE INDEX ix_match_complete_match ON project.match (sender_id,receiver_id);

CREATE INDEX ix_in_app_conversation_match_id ON project.in_app_conversation (match_id);
