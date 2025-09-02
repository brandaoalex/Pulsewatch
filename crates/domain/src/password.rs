
use argonautica::{Hasher, Verifier};
pub struct ArgonPassword {
    password: String,
    secret_key: String,
}
impl ArgonPassword {
    // todo: move to config the secret key
    pub fn new(password: String) -> Self {
        Self {
            password,
            secret_key: String::from("$argon2id$v=19$m=4096,t=192,p=4$o2y5PU86Vt+sr93N7YUGgC7AMpTKpTQCk4tNGUPZMY4$yzP/ukZRPIbZg6PvgnUUobUMbApfF9RH6NagL9L4Xr4"),
        }
    }

    pub fn hash_password_argon2ID(&self) -> Result<String, argonautica::Error> {
        let mut hasher = Hasher::default();
        let hash = hasher
            .with_password(self.password.clone())
            .with_secret_key(format!("{}", self.secret_key)).hash();
        hash
    }

    pub fn verify_password(&self, password: String) -> Result<bool, argonautica::Error> {
        let mut verifier = Verifier::default();
        let is_valid = verifier
            .with_password(password).with_secret_key(format!("{}", self.secret_key)).verify();
        is_valid
    }
}