#!/bin/bash
echo "task#1"
curl -fsSL "https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer" | bash
echo "task#2"
echo 'eval "$(~/.rbenv/bin/rbenv init - bash)"' >> ~/.bash_profile && source ~/.bash_profile
echo "task#3"
rbenv install 2.6.10 && rbenv global 2.6.10 && ruby -v
