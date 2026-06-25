-- PRAGMA foreign_keys = OFF;

CREATE TEMP TABLE _user_id_map (
    old_id TEXT PRIMARY KEY,
    new_id TEXT NOT NULL
);

INSERT INTO _user_id_map (old_id, new_id)
-- adapted from https://stackoverflow.com/a/61000724
SELECT
    userID,
    lower(hex( randomblob(4)) || '-' || hex( randomblob(2))
         || '-' || '4' || substr( hex( randomblob(2)), 2) || '-'
         || substr('AB89', 1 + (abs(random()) % 4) , 1)  ||
         substr(hex(randomblob(2)), 2) || '-' || hex(randomblob(6)))
FROM users
WHERE cast(cast(userID AS INTEGER) AS TEXT) == userID;

UPDATE recovery SET recoveryOwnerID = (
    SELECT new_id FROM _user_id_map WHERE old_id = recoveryOwnerID
) WHERE recoveryOwnerID IN (SELECT old_id FROM _user_id_map);

UPDATE otp SET otpOwnerID = (
    SELECT new_id FROM _user_id_map WHERE old_id = otpOwnerID
) WHERE otpOwnerID IN (SELECT old_id FROM _user_id_map);

UPDATE devices SET deviceOwnerID = (
    SELECT new_id FROM _user_id_map WHERE old_id = deviceOwnerID
) WHERE deviceOwnerID IN (SELECT old_id FROM _user_id_map);

UPDATE users SET userID = (
    SELECT new_id FROM _user_id_map WHERE old_id = userID
) WHERE userID IN (SELECT old_id FROM _user_id_map);

DROP TABLE _user_id_map;

-- PRAGMA foreign_keys = ON;
