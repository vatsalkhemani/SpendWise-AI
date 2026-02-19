# Phase 4 Testing Guide

**Date:** 2026-02-16
**Test Credentials:** vatsalkhemani3@gmail.com / Sanjay.64Vatsal.994240
**App URL:** http://localhost:8088

---

## Pre-Testing Checklist

- [ ] App launched successfully on Chrome
- [ ] Signed in with Google account
- [ ] Dashboard loads with existing data
- [ ] All 5 tabs visible: Chat, Dashboard, Analytics, Categories, AI Chat

---

## Phase 4a: Expense Management (Edit/Delete)

### Test 1: Edit Expense from Dashboard
1. Navigate to **Dashboard** tab
2. Find any expense in the "Recent Expenses" list
3. Click the **Edit icon** (pencil) next to the expense
4. **Expected:** Edit dialog opens with pre-filled fields
5. Modify the amount or description
6. Click **Save**
7. **Expected:** Expense updates immediately, SnackBar shows "Expense updated"
8. **Expected:** Changes sync to Firestore (check other device/incognito)

**Status:** [ ] PASS [ ] FAIL
**Notes:**

---

### Test 2: Delete Expense from Dashboard
1. Navigate to **Dashboard** tab
2. Find any expense in the "Recent Expenses" list
3. Click the **Delete icon** (trash) next to the expense
4. **Expected:** Confirmation dialog appears
5. Click **Delete**
6. **Expected:** Expense disappears immediately, SnackBar shows "Expense deleted"
7. **Expected:** Deletion syncs to Firestore

**Status:** [ ] PASS [ ] FAIL
**Notes:**

---

## Phase 4b: Advanced Analytics

### Test 3: Navigate to Analytics Tab
1. Click on the **Analytics** tab (3rd tab, chart icon)
2. **Expected:** Analytics screen loads with:
   - Month comparison card at top
   - 6-month spending trend line chart
   - 4 quick stats cards (Total, Monthly Avg, Transactions, Avg/Transaction)
   - AI Insights section with "Generate" button

**Status:** [ ] PASS [ ] FAIL
**Notes:**

---

### Test 4: Month-over-Month Comparison
1. In Analytics tab, view the **"This Month vs Last Month"** card
2. **Expected:** Shows 3 values:
   - This Month: $X.XX
   - Last Month: $Y.YY
   - Change: ↑/↓ Z% (red arrow if increase, green if decrease)
3. Verify calculations are accurate

**Status:** [ ] PASS [ ] FAIL
**Notes:**

---

### Test 5: 6-Month Spending Trend Chart
1. In Analytics tab, scroll to **"6-Month Spending Trend"** chart
2. **Expected:** Line chart shows spending for last 6 months
3. **Expected:** Yellow line with gradient fill below
4. **Expected:** Y-axis shows dollar amounts, X-axis shows month numbers
5. Hover over chart (if interactive) to see values

**Status:** [ ] PASS [ ] FAIL
**Notes:**

---

### Test 6: Quick Stats Cards
1. In Analytics tab, view the 4 stats cards:
   - **Total Spent:** Sum of all expenses
   - **Monthly Avg:** Average spending per month
   - **Transactions:** Total count
   - **Avg/Transaction:** Average per expense
2. Verify calculations match actual data

**Status:** [ ] PASS [ ] FAIL
**Notes:**

---

### Test 7: AI Insights Generation
1. In Analytics tab, scroll to **"AI Insights"** section
2. Click **"Generate"** button
3. **Expected:** Button shows "Loading..." with spinner
4. Wait 5-10 seconds for Azure OpenAI response
5. **Expected:** Two insight cards appear:
   - **Spending Summary:** AI-generated paragraph about spending patterns
   - **Money-Saving Tips:** Bulleted list of personalized recommendations
6. Read insights to verify they make sense

**Status:** [ ] PASS [ ] FAIL
**Notes:**

---

## Phase 4c: Category Budgets

### Test 8: Set Monthly Budget for Category
1. Navigate to **Categories** tab
2. Find any category (e.g., "Food & Dining")
3. Click the **wallet icon** (or + icon) next to the category
4. **Expected:** "Set Budget" dialog opens
5. Enter a budget amount (e.g., $500)
6. Click **Save**
7. **Expected:** Budget progress bar appears under the category
8. **Expected:** Shows "Budget: $500.00" and "X% used"
9. **Expected:** Progress bar color:
   - Green if < 80% used
   - Orange if 80-100% used
   - Red if > 100% used (over budget)

**Status:** [ ] PASS [ ] FAIL
**Notes:**

---

### Test 9: Over-Budget Warning
1. In Categories tab, find a category with a budget set
2. Add expenses to that category until it exceeds the budget
3. **Expected:** Progress bar turns red
4. **Expected:** Shows "Over budget by $X.XX" warning in red text

**Status:** [ ] PASS [ ] FAIL
**Notes:**

---

### Test 10: Remove Budget
1. In Categories tab, click wallet icon on a category with a budget
2. Clear the budget field (leave empty)
3. Click **Save**
4. **Expected:** Budget progress bar disappears
5. **Expected:** SnackBar shows "Budget removed"

**Status:** [ ] PASS [ ] FAIL
**Notes:**

---

## Phase 4d: Search & Filters

### Test 11: Search Expenses
1. Navigate to **Dashboard** tab
2. Click the **"View All Expenses"** button (if exists) or **filter icon** in AppBar
3. **Expected:** Navigates to "All Expenses" screen
4. Type in the search bar: e.g., "coffee"
5. **Expected:** List filters to show only expenses with "coffee" in description or person name
6. Clear search (X button)
7. **Expected:** All expenses reappear

**Status:** [ ] PASS [ ] FAIL
**Notes:**

---

### Test 12: Filter by Category
1. In "All Expenses" screen, click **filter icon** (top-right)
2. In "Filter Expenses" dialog, select a category from dropdown
3. Click **Apply**
4. **Expected:** Only expenses from that category show
5. **Expected:** Category chip appears below search bar
6. Click X on the chip to remove filter
7. **Expected:** All expenses reappear

**Status:** [ ] PASS [ ] FAIL
**Notes:**

---

### Test 13: Filter by Date Range
1. In "All Expenses" screen, click **filter icon**
2. Click **"Select Date Range"** button
3. Pick a start and end date (e.g., last week)
4. Click **Apply**
5. **Expected:** Only expenses within that date range show
6. **Expected:** Date range chip appears (e.g., "2/10 - 2/16")
7. Click **"Clear Filters"** button
8. **Expected:** All expenses reappear

**Status:** [ ] PASS [ ] FAIL
**Notes:**

---

### Test 14: Filter by Amount Range
1. In "All Expenses" screen, click **filter icon**
2. Enter Min: $10, Max: $50
3. Click **Apply**
4. **Expected:** Only expenses between $10-$50 show
5. **Expected:** Amount range chip appears (e.g., "$10 - $50")

**Status:** [ ] PASS [ ] FAIL
**Notes:**

---

## Phase 4e: Data Export

### Test 15: Export to CSV
1. Navigate to **Dashboard** tab
2. Click the **3-dot menu icon** (top-right corner)
3. Select **"Export to CSV"**
4. **Expected:** Browser downloads a file named `expenses_YYYYMMDD.csv`
5. Open the CSV file
6. **Expected:** Contains columns: Date, Description, Amount, Category, Person
7. **Expected:** All current expenses are listed

**Status:** [ ] PASS [ ] FAIL
**Notes:**

---

### Test 16: Export to Report
1. In Dashboard, click **3-dot menu** → **"Export Report"**
2. **Expected:** Browser downloads a file named `expense_report_YYYYMMDD.txt`
3. Open the text file
4. **Expected:** Contains:
   - Header with date range
   - List of all expenses
   - Category breakdowns with totals
   - Grand total at bottom
5. Verify report formatting is readable

**Status:** [ ] PASS [ ] FAIL
**Notes:**

---

## Phase 4f: Recurring Expenses

### Test 17: Navigate to Recurring Expenses
1. Navigate to **Categories** tab
2. Click the **recurring icon** (repeat symbol) in the AppBar
3. **Expected:** Opens "Recurring Expenses" screen
4. **Expected:** Shows empty state if no recurring expenses yet

**Status:** [ ] PASS [ ] FAIL
**Notes:**

---

### Test 18: Create Monthly Recurring Expense
1. In "Recurring Expenses" screen, click **+ (Add)** button
2. Fill in the dialog:
   - Description: "Netflix Subscription"
   - Amount: $15.99
   - Category: "Entertainment"
   - Frequency: "Monthly"
   - End Date: (leave blank or set 1 year from now)
3. Click **Create**
4. **Expected:** SnackBar shows "Recurring expense created"
5. **Expected:** Card appears showing:
   - Badge with "Monthly"
   - Description "Netflix Subscription"
   - Amount $15.99
   - "0 payments made" (will be 1 after first auto-generation)

**Status:** [ ] PASS [ ] FAIL
**Notes:**

---

### Test 19: Auto-Generation of Recurring Instances
1. After creating a recurring expense, wait or manually trigger
2. Check **Dashboard** → Recent Expenses
3. **Expected:** Should see an expense instance auto-generated
4. **Expected:** Expense has a yellow "Recurring" badge
5. **Expected:** Shows "From recurring expense" in details

**Status:** [ ] PASS [ ] FAIL
**Notes:**

---

### Test 20: Stop Recurring Expense
1. In "Recurring Expenses" screen, find the recurring expense
2. Click **"Stop"** button
3. **Expected:** Confirmation dialog appears
4. Click **Stop**
5. **Expected:** Card shows "STOPPED" badge in gray
6. **Expected:** No more instances will be auto-generated
7. **Expected:** Badge turns gray, "Stop" button disappears

**Status:** [ ] PASS [ ] FAIL
**Notes:**

---

### Test 21: Delete Recurring Template and All Instances
1. In "Recurring Expenses" screen, find any recurring expense
2. Click **"Delete All"** button
3. **Expected:** Confirmation dialog shows: "This will delete the template and all X payment records."
4. Click **Delete All**
5. **Expected:** SnackBar shows "Recurring expense deleted"
6. **Expected:** Card disappears from recurring expenses screen
7. Check **Dashboard** → All expenses should also be deleted

**Status:** [ ] PASS [ ] FAIL
**Notes:**

---

## Phase 4g: Multi-Device Sync (Firestore)

### Test 22: Real-Time Sync Across Devices
1. Open the app in **two browser windows** (or incognito mode)
2. Sign in with the same Google account in both
3. In Window A: Add a new expense via Chat
4. **Expected:** Expense appears in Window B within 1-3 seconds
5. In Window B: Edit the expense
6. **Expected:** Changes appear in Window A within 1-3 seconds
7. In Window A: Delete the expense
8. **Expected:** Expense disappears from Window B

**Status:** [ ] PASS [ ] FAIL
**Notes:**

---

### Test 23: Sync Status Indicator
1. Navigate to **Dashboard** tab
2. Look at the **top-right corner** of the AppBar
3. **Expected:** Cloud icon appears:
   - **Yellow cloud:** Syncing in progress
   - **Green cloud:** Synced successfully
   - **No cloud:** If offline or sync disabled
4. Add a new expense and watch the cloud icon change colors

**Status:** [ ] PASS [ ] FAIL
**Notes:**

---

## Critical Bug Check

### Test 24: No Compilation Errors
1. In the terminal running `flutter run`, check for any errors
2. **Expected:** No red error messages
3. **Expected:** Hot reload works when pressing 'r'

**Status:** [ ] PASS [ ] FAIL
**Notes:**

---

### Test 25: No Console Errors (Browser)
1. Open Chrome DevTools (F12)
2. Go to **Console** tab
3. Navigate through all app screens
4. **Expected:** No critical errors (some warnings about Google Sign-In deprecation are OK)

**Status:** [ ] PASS [ ] FAIL
**Notes:**

---

## Final Checks

- [ ] All 5 tabs work without crashes
- [ ] Data persists after refresh (Hive local storage)
- [ ] Data syncs across devices (Firestore)
- [ ] AI features work (Azure OpenAI)
- [ ] No memory leaks or performance issues
- [ ] Export files download successfully
- [ ] Recurring expenses auto-generate correctly

---

## Summary

**Total Tests:** 25
**Passed:** ___
**Failed:** ___
**Blocked:** ___

**Overall Status:** [ ] READY FOR PRODUCTION [ ] NEEDS FIXES

---

## Notes & Issues Found

(Add any bugs, issues, or observations here)

---

**Tester:** _______________
**Date Completed:** _______________
**Time Spent:** _______________
