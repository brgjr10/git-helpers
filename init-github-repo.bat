@echo off
title Initialize GitHub Repo
powershell -ExecutionPolicy Bypass -File "%~dp0init-github-repo.ps1"
pause