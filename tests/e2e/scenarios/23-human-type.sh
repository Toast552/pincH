#!/bin/bash
# 23-human-type.sh — humanType and humanClick actions

source "$(dirname "$0")/common.sh"

# ─────────────────────────────────────────────────────────────────
start_test "humanClick: click input by ref"

pt_post /navigate -d "{\"url\":\"${FIXTURES_URL}/human-type.html\"}"
sleep 1

# Get snapshot to populate ref cache
pt_get /snapshot
assert_ok "snapshot loaded"

# Find the email input ref
EMAIL_REF=$(echo "$RESULT" | jq -r '[.nodes[] | select(.role=="textbox" and .name=="Email")][0].ref')
if [ -z "$EMAIL_REF" ] || [ "$EMAIL_REF" = "null" ]; then
  echo -e "  ${RED}✗${NC} could not find Email textbox ref"
  ((ASSERTIONS_FAILED++)) || true
else
  echo -e "  ${GREEN}✓${NC} found Email ref: $EMAIL_REF"
  ((ASSERTIONS_PASSED++)) || true

  # humanClick on the input
  pt_post /action -d "{\"kind\":\"humanClick\",\"ref\":\"$EMAIL_REF\"}"
  assert_ok "humanClick on email input"
fi

end_test

# ─────────────────────────────────────────────────────────────────
start_test "humanType: type into input by ref"

# Re-fetch snapshot for fresh refs
pt_get /snapshot
EMAIL_REF=$(echo "$RESULT" | jq -r '[.nodes[] | select(.role=="textbox" and .name=="Email")][0].ref')

if [ -z "$EMAIL_REF" ] || [ "$EMAIL_REF" = "null" ]; then
  echo -e "  ${RED}✗${NC} could not find Email textbox ref"
  ((ASSERTIONS_FAILED++)) || true
else
  # humanType into the email field
  pt_post /action -d "{\"kind\":\"humanType\",\"ref\":\"$EMAIL_REF\",\"text\":\"test@example.com\"}"
  assert_ok "humanType into email input"

  # Verify the text was typed
  pt_get /snapshot
  TYPED_VALUE=$(echo "$RESULT" | jq -r '[.nodes[] | select(.role=="textbox" and .name=="Email")][0].value // empty')
  if echo "$TYPED_VALUE" | grep -q "test@example.com"; then
    echo -e "  ${GREEN}✓${NC} value is: $TYPED_VALUE"
    ((ASSERTIONS_PASSED++)) || true
  else
    echo -e "  ${RED}✗${NC} expected 'test@example.com', got: '$TYPED_VALUE'"
    ((ASSERTIONS_FAILED++)) || true
  fi
fi

end_test

# ─────────────────────────────────────────────────────────────────
start_test "humanType: type into second input by ref"

# Get fresh snapshot
pt_get /snapshot
NAME_REF=$(echo "$RESULT" | jq -r '[.nodes[] | select(.role=="textbox" and .name=="Name")][0].ref')

if [ -z "$NAME_REF" ] || [ "$NAME_REF" = "null" ]; then
  echo -e "  ${RED}✗${NC} could not find Name textbox ref"
  ((ASSERTIONS_FAILED++)) || true
else
  pt_post /action -d "{\"kind\":\"humanType\",\"ref\":\"$NAME_REF\",\"text\":\"John Doe\"}"
  assert_ok "humanType into name input"

  pt_get /snapshot
  TYPED_VALUE=$(echo "$RESULT" | jq -r '[.nodes[] | select(.role=="textbox" and .name=="Name")][0].value // empty')
  if echo "$TYPED_VALUE" | grep -q "John Doe"; then
    echo -e "  ${GREEN}✓${NC} value is: $TYPED_VALUE"
    ((ASSERTIONS_PASSED++)) || true
  else
    echo -e "  ${RED}✗${NC} expected 'John Doe', got: '$TYPED_VALUE'"
    ((ASSERTIONS_FAILED++)) || true
  fi
fi

end_test

# ─────────────────────────────────────────────────────────────────
start_test "humanType: type with CSS selector"

pt_post /action -d "{\"kind\":\"humanType\",\"selector\":\"#name\",\"text\":\" Jr.\"}"
assert_ok "humanType with CSS selector"

end_test
