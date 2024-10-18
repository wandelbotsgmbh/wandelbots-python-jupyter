from flask import Flask, Response, send_file, redirect, request
import requests
import os

app = Flask(__name__)

BASE_PATH = os.getenv('BASE_PATH', '')

@app.route(f'{BASE_PATH}/app_icon.png')
def serve_image():
    image_path = '/app/static/app_icon.png'
    if os.path.exists(image_path):
        return send_file(image_path, mimetype='image/png')
    else:
        return "Image not found", 404
    
@app.route(f'{BASE_PATH}/<path:path>', methods=['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'])
def proxy_notebook(path):
    url = f'http://0.0.0.0:3001/{path}'
    method = request.method
    headers = {key: value for key, value in request.headers if key.lower() != 'host'}
    
    # Extract the _xsrf token from cookies and add it to headers
    if '_xsrf' in request.cookies:
        headers['X-XSRFToken'] = request.cookies['_xsrf']
    
    # Pass query parameters
    params = request.args.to_dict()
    
    # Pass cookies
    cookies = request.cookies
    
    data = request.get_data()
    response = requests.request(method, url, headers=headers, params=params, data=data, cookies=cookies, stream=True)
    
    # Forward all headers from the response
    headers = [(name, value) for name, value in response.raw.headers.items()]
    
    return Response(response.content, response.status_code, headers)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3000)