Wagtail multilanguage module
============================

Features
========

* Support multiple language for your wagtail site


Getting started
===============

1. To install wagtailtrans, run this command in your terminal:

.. code-block:: console
    ``pip install wagtailtrans``

2. Add ``wagtailtrans`` to your INSTALLED_APPS

3. Perform a migration

.. code-block:: console
    ``python manage.py migrate wagtailtrans``

You're set!

Settings
========

The settings ``WAGTAILTRANS_SYNC_TREE`` can be used to configure the module to keep your language trees synchronized or not.
This is set to ``True`` by default.

Use ``WAGTAILTRANS_SYNC_TREE = False`` to disable sync and have free flowing trees.
