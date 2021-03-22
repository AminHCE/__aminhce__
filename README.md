# AminHCE resume generator

*__AminHCE__* is my own website repository. This website will complete as soon as possible. For now this website can collect resume information and show them in page witch is print friendly. This website work with two LTR and RTL page design.

![Screenshot of generated resume](https://user-images.githubusercontent.com/30463764/107969007-5d07d680-6fc4-11eb-93bf-e38cb89511b9.png)

## Deployment

If you interested in using this web service. This is a guide to deploy this application on your own server or local system.

### Prerequisites

- Installing [Python 3](https://www.python.org/download/releases/3.0/)
- Create a [virtual environments](https://docs.python.org/3/library/venv.html)

### Installing

1. Clone the [AminHCE](https://github.com/AminHCE/__aminhce__) project:

    ```bash
    git clone https://github.com/AminHCE/__aminhce__.git
    ```
   
2. Active your venv:

    ```bash
    source path/to/venv/bin/activate
    ```

3. Go to **AminHCE** root and install requirements:

    ```bash
    pip install -r requirements.txt
    ```

4. Run the Django server on local

    ```bash
    python3 manage.py runserver
    ```
   
    if you see these lines in your terminal, every thing is ok
    ```bash
    Watching for file changes with StatReloader
    Performing system checks...
    
    System check identified no issues (0 silenced).
    February 15, 2021 - 16:42:00
    Django version 3.1.6, using settings 'config.settings.settings'
    Starting development server at http://127.0.0.1:8000/
    Quit the server with CONTROL-C.
    ```

## Useing webservice

##### Create superuser

befor login to Django administration, you need to create a superuser.

```bash
python3 manage.py createsuperuser
```
enter your username, email and password.

##### Login to administration panel

Easly open [local host](http://localhost:8000/admin) and login with your username and password. After login you can add 
and edit your 
___Information___, ___Education___, ___Certificates___, ___Experiences___, ___Projects___ and ___Skills___.

##### See resume page

Visit this url for [English resume](http://localhost:8000/resume/en) and this url for [Farsi resume](http://localhost:8000/resume/fa)

## License

This project is licensed under the BSD 3-Clause License - see the [LICENSE](LICENSE) file for details
