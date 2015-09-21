# Adding Wikis

This manual explains how to add wikis to your Meza1 install. There are two methods for adding wikis:

1. Creating a new wiki from scratch
2. Importing one or more wikis

## Creating a new wiki

To create a new wiki you use the `create-wiki.sh` script.

```bash
sudo bash create-wiki.sh
```

This script will then ask for three inputs:

1. *MySQL root password*: The password for your MySQL root user
2. *Wiki ID*: This is an alphanumeric identifier for your wiki. It will be used in the URL (like `http://example.com/yourID`), and throughout the server configuration. It should be something short and simple. For example, if you're creating a wiki for your Human Resources department, a good wiki ID would be "hr". All lowercase is preferred.
3. *Wiki Name*: This should be a more descriptive title for your wiki. It still should not be too long, though. For the same example you may choose "Human Resources Wiki" or "HR Wiki"

## Importing existing wikis

To import one more more existing wikis you use the `import-wikis.sh` script.

```bash
sudo bash import-wikis.sh
```

This script will ask for two inputs:

1. *Import directory*: The directory where all your files for import are located. See below for more details.
2. *MySQL root password*: The password for your MySQL root user

### Creating the import directory

Your import directory should be called something like "wikis" and should have directories within it each named with a wiki identifier. So if you had wikis for your Human Resources (hr), Sales (sales) and Engineering (eng) departments, you may have a setup like this:

```
wikis
	hr
	sales
	eng
```

If you have this directory in root's user directory, you would enter `/root/wikis/` for step 1 above. Note that using `~/wikis/` doesn't seem to work.

Each of these identifiers will be used throughout Meza1, but the place you'll notice it most is in your URLs. For example, your Engineering Department's wiki may be at `https://example.com/eng`.

Within each of these directories you put each wiki's information. This includes the `images` directory and a `wiki.sql` file to build your database, as well as an optional `config` directory. The `eng` directory may look like this:

```
eng
	images
	config
		logo.png
		favicon.ico
		setup.php
		CustomSettings.php
	wiki.sql
```

The `images` directory should be directly copied from your current wiki.

The contents of `config` are as follows:

* `logo.png` is the image that is displayed in the top-right of your wiki.
* `favicon.ico` is the wikis [favicon](https://en.wikipedia.org/wiki/Favicon).
* `setup.php` has some Meza1-specific configuration variables in it. If you don't already have this file, let the install process generate one for you.
* `CustomSettings.php` will also be auto-generated. It contains any settings specific to this particular wiki, different from your other wikis. Ideally it should be blank (keep all your wikis configured the same way).

The `wiki.sql` file is what will build your database. You can generate this file by running the `mysqldump` command on your current wiki. The command may look something like: `mysqldump -u my_username -p my_database > /path/to/your/output/file.sql`

