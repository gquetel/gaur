from setuptools import setup, find_packages

setup(
    name="pygaur",
    version="0.1.0",
    packages=find_packages(),
    entry_points={
        'console_scripts': [
            'gclassify=pygaur.gclassify:main',
        ],
    },
)
