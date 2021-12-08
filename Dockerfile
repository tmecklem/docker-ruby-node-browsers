from ruby:2.4.10-buster
SHELL ["/bin/bash", "-c"]

USER root
WORKDIR /root

# Install system deps
RUN apt-get --allow-releaseinfo-change -qq update && \
    apt-get install -y build-essential libpq-dev git libdbus-glib-1-2 phantomjs
                       
# Install chrome 
RUN curl https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o /chrome.deb
RUN dpkg -i /chrome.deb || apt-get install -yf
RUN rm /chrome.deb

# Create workspace folder
ENV APP_ROOT /workspace
RUN mkdir -p $APP_ROOT

# Setup app user
RUN useradd -ms /bin/bash vscode
RUN chown -R vscode:vscode ${APP_ROOT}
USER vscode

RUN mkdir -p $HOME/bin
WORKDIR /home/vscode
ENV HOME=/home/vscode
ENV PATH="$HOME/bin:$HOME/.asdf/bin:$HOME/.asdf/shims:$PATH"
ENV QT_QPA_PLATFORM=offscreen
ENV FIREFOX_VERSION=95.0
                       
RUN git clone https://github.com/asdf-vm/asdf.git $HOME/.asdf --branch v0.8.1
RUN echo "source $HOME/.asdf/asdf.sh" >> $HOME/.bashrc
RUN source $HOME/.bashrc 
RUN asdf plugin add nodejs
RUN asdf plugin add ruby
RUN asdf install ruby 2.4.10
RUN asdf global ruby 2.4.10
RUN asdf install nodejs 6.11.1
RUN asdf global nodejs 6.11.1

# Set working directory as APP_ROOT
WORKDIR $APP_ROOT
RUN mkdir -p ~/cache

RUN curl -sSL https://raw.githubusercontent.com/codeship/scripts/master/packages/firefox.sh | bash -s
ENV PATH="$HOME/firefox:$PATH"

RUN gem install foreman

CMD ["bash"]
