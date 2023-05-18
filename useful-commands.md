### Switch tilde to non_us_backslack on non standard US keyboards

```
hidutil property --set '{"UserKeyMapping": [{"HIDKeyboardModifierMappingSrc": 0x700000064, "HIDKeyboardModifierMappingDst": 0x700000035}, {"HIDKeyboardModifierMappingSrc": 0x700000035, "HIDKeyboardModifierMappingDst": 0x700000064}]}'
```

### Reset tilde

```
hidutil property --set '{"UserKeyMapping":[]}'
```
