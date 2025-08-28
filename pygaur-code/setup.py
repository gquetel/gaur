from setuptools import setup, find_packages

setup(
    name="pygaur",
    version="0.1.0",
    packages=find_packages(),
    scripts=["gclassify.py", "convert_tags.py"]
)
