UPDATE users SET email = concat('user+', substr(id::text,1,8), '@example.com'), password_hash = NULL;
