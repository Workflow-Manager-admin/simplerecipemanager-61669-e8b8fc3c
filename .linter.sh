#!/bin/bash
cd /home/kavia/workspace/code-generation/simplerecipemanager-61669-e8b8fc3c/simplerecipe_manager
npm run lint
ESLINT_EXIT_CODE=$?
npm run build
BUILD_EXIT_CODE=$?
if [ $ESLINT_EXIT_CODE -ne 0 ] || [ $BUILD_EXIT_CODE -ne 0 ]; then
   exit 1
fi

