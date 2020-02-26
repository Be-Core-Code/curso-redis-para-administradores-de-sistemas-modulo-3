FROM becorecode/revealjs:3.8.0

LABEL com.becorecode.author="Alfonso Alba García"
LABEL com.becorecode.author_email="hola@becorecode.com"

COPY --chown=node . $APP_PATH
