---
number: 81
labels: tech debt, scale
milestone: Future
size: L
release: 
status: open
---

# Permissions registry

A new permission registry to make it easier for developers to manage permissions across their code.

## Intended outcome

- New registry that maps a model class to a permission configuration.
- Everywhere a permission test is performed in Wagtail, the registry determines the configuration to use for the model or model instance in question.
- Easier for developers to access the permission configuration of a model from anywhere in the code.
- Allow developers to define custom permission logic for both custom models and Wagtail's built-in models, to be used in place of the default.

## More information

See [RFC 102: Permissions registry](https://github.com/wagtail/rfcs/pull/102).
