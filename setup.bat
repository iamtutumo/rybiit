@echo off
echo Setting up Rybbit for local development...

:: Check if .env exists, if not create it
if not exist ".env" (
    echo Creating .env file...
    copy ".env.example" ".env" >nul
    echo DOMAIN_NAME=localhost:8080>> ".env"
    echo BASE_URL=http://localhost:8080>> ".env"
    echo BACKEND_PORT=3001>> ".env"
    echo CLIENT_PORT=3002>> ".env"
    echo DISABLE_WEBSERVER=true>> ".env"
)

:: Check if nginx.conf exists in nginx directory
echo Checking Nginx configuration...
if not exist "%NGINX_HOME%\conf\nginx.conf.rybbit.backup" (
    echo Backing up original nginx.conf...
    copy "%NGINX_HOME%\conf\nginx.conf" "%NGINX_HOME%\conf\nginx.conf.rybbit.backup"
)

:: Copy our nginx configuration
echo Updating Nginx configuration...
copy "nginx.sample.conf" "%NGINX_HOME%\conf\nginx.conf"

:: Restart Nginx
echo Restarting Nginx...
net stop nginx
net start nginx

:: Install dependencies and start services
echo Installing dependencies...
cd server && npm install
cd ../client && npm install
cd ../shared && npm install

:: Start the services
echo Starting services...
start cmd /k "cd server && npm run dev"
start cmd /k "cd client && npm run dev"

echo Setup complete! Access Rybbit at http://localhost:8080
echo Press any key to exit...
pause > nul