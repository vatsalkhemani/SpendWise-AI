# Firebase Console Setup Guide

**Project:** SpendWise AI
**Firebase Project ID:** spendwise-ai-5b1ff
**Phase:** Phase 3 - Firestore Cloud Sync

---

## Prerequisites

✅ Firebase project exists (spendwise-ai-5b1ff)
✅ Firebase Authentication enabled (Google Sign-In working)
✅ Firebase Core initialized in app
✅ Code implementation complete

---

## Step-by-Step Setup

### 1. Enable Firestore Database (5 minutes)

1. **Open Firebase Console**
   - Go to: https://console.firebase.google.com
   - Select project: **spendwise-ai-5b1ff**

2. **Navigate to Firestore Database**
   - Click **"Firestore Database"** in left sidebar
   - Click **"Create database"** button

3. **Choose Location**
   - Select: **us-central1** (or your nearest region)
   - Note: Location **cannot be changed** after creation

4. **Security Mode**
   - Choose: **"Start in production mode"**
   - We'll add custom security rules next

5. **Wait for Creation**
   - Takes ~30 seconds
   - Status: "Cloud Firestore is ready"

---

### 2. Configure Security Rules (3 minutes)

**Why:** Protect user data, ensure only authenticated users access their own expenses

1. **Go to Rules Tab**
   - Click **"Rules"** tab in Firestore Database

2. **Replace Default Rules**
   - Delete existing rules
   - Copy and paste this:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User data isolation
    match /users/{userId} {
      // Only authenticated users can access their own data
      allow read, write: if request.auth != null && request.auth.uid == userId;

      // Expenses subcollection
      match /expenses/{expenseId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }

      // Categories subcollection
      match /categories/{categoryId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

3. **Publish Rules**
   - Click **"Publish"** button
   - Confirm deployment

4. **Verify Rules**
   - Check for green checkmark: "Rules published"

**What These Rules Do:**
- ✅ Only signed-in users can access Firestore
- ✅ Users can only read/write their own data
- ✅ Data isolated by user ID (`users/{userId}/...`)
- ❌ No anonymous access
- ❌ No cross-user data access

---

### 3. Create Composite Indexes (5 minutes)

**Why:** Firestore requires indexes for sorting and filtering queries

#### Index 1: Expenses by Date (for dashboard)

1. **Start Index Creation**
   - Go to **"Indexes"** tab
   - Click **"Create Index"** (or "+" button)

2. **Configure Index**
   - Collection ID: `expenses`
   - Add fields in this order:

   | Field Name | Order      |
   |------------|-----------|
   | userId     | Ascending |
   | date       | Descending |

   - Query scope: **Collection**

3. **Create Index**
   - Click **"Create index"**
   - Status: "Building..." (takes 1-3 minutes)

#### Index 2: Expenses by Category and Date (for filtering)

1. **Create Another Index**
   - Click **"Create Index"** again

2. **Configure Index**
   - Collection ID: `expenses`
   - Add fields in this order:

   | Field Name | Order      |
   |------------|-----------|
   | userId     | Ascending |
   | category   | Ascending |
   | date       | Descending |

   - Query scope: **Collection**

3. **Create Index**
   - Click **"Create index"**
   - Wait for building...

#### Index 3: Categories by Update Time (for recent changes)

1. **Create Third Index**
   - Click **"Create Index"** again

2. **Configure Index**
   - Collection ID: `categories`
   - Add fields in this order:

   | Field Name | Order      |
   |------------|-----------|
   | userId     | Ascending |
   | updatedAt  | Descending |

   - Query scope: **Collection**

3. **Create Index**
   - Click **"Create index"**
   - Wait for all indexes to complete

4. **Verify Indexes Built**
   - All 3 indexes should show status: **"Enabled"** (green)
   - If "Building", wait 2-5 minutes

---

### 4. Verify Setup (2 minutes)

1. **Check Firestore Dashboard**
   - Go to **"Data"** tab
   - Should see empty database (no collections yet)
   - Collections will appear when app runs

2. **Check Rules Status**
   - Rules tab shows: "Last published: Just now"

3. **Check Indexes Status**
   - Indexes tab shows: 3 indexes, all "Enabled"

---

## Testing the Setup

### Test 1: Run the App

1. **Start the app**
   ```bash
   flutter run -d chrome --web-port=8085
   ```

2. **Sign in with Google**
   - Use your Google account

3. **Check Console Logs**
   - Look for these messages:
   ```
   🔄 Starting Firestore listeners for user: {userId}
   🔄 Migrating local data to Firestore for user: {userId}
   ✅ Migration complete: X expenses, Y categories
   ```

### Test 2: Verify Data in Firestore

1. **Add an Expense in App**
   - Enter: "spent $50 on dinner"
   - Wait 2-3 seconds

2. **Check Firebase Console**
   - Go to Firestore → Data tab
   - Navigate: `users → {your-user-id} → expenses`
   - Should see expense document appear

3. **Verify Fields**
   - id, userId, amount, category, description
   - date, createdAt, updatedAt (timestamps)

### Test 3: Multi-Device Sync

1. **Open Second Browser (Incognito)**
   - Go to: http://localhost:8085
   - Sign in with **same Google account**

2. **Add Expense on Device A**
   - Enter: "spent $25 on coffee"

3. **Check Device B**
   - Expense should appear within 3 seconds
   - Dashboard updates automatically

4. **Add Expense on Device B**
   - Enter: "spent $15 on snacks"

5. **Check Device A**
   - Verify new expense appears

**Expected Behavior:**
- ✅ Expenses sync in both directions
- ✅ Latency: 1-3 seconds
- ✅ Dashboard updates automatically
- ✅ No page refresh needed

### Test 4: Offline Mode

1. **Disconnect Internet**
   - Turn off Wi-Fi or unplug ethernet

2. **Add Expense in App**
   - Should still work (writes to Hive)
   - Sync indicator shows yellow (syncing)

3. **Reconnect Internet**
   - Wait 2-3 seconds
   - Sync indicator turns green
   - Check Firestore Console - expense should appear

---

## Common Issues & Solutions

### Issue: "Missing or insufficient permissions"

**Symptom:** Console error when adding expense

**Cause:** Security rules not published or user not authenticated

**Fix:**
1. Go to Firestore → Rules tab
2. Verify rules are published (green checkmark)
3. Check user is signed in (Firebase Auth console)
4. Try signing out and back in

---

### Issue: "Index not found" error

**Symptom:** Console error: "The query requires an index"

**Cause:** Composite indexes not created or still building

**Fix:**
1. Go to Firestore → Indexes tab
2. Check all 3 indexes are "Enabled" (not "Building")
3. If missing, create indexes (see Step 3 above)
4. Wait 2-5 minutes for indexes to build
5. Refresh app

---

### Issue: Data not appearing in Firestore

**Symptom:** App works but Firestore Console shows no data

**Cause:** Network error or sync not enabled

**Fix:**
1. Check browser console for errors
2. Look for "✅ Synced expense to Firestore" log
3. Verify internet connection
4. Check Firebase Console → Firestore → Quotas (not exceeded)
5. Try signing out and back in

---

### Issue: Duplicate data on sync

**Symptom:** Expenses appear twice after sign-in

**Cause:** Migration running multiple times

**Fix:**
- This shouldn't happen (migration uses SharedPreferences flag)
- If it does:
  1. Sign out
  2. Clear browser storage (DevTools → Application → Storage)
  3. Sign in again
  4. Migration should run once

---

### Issue: "Quota exceeded" error

**Symptom:** Firestore operations fail after many syncs

**Cause:** Free tier limits exceeded (unlikely in development)

**Fix:**
1. Go to Firebase Console → Firestore → Quotas
2. Check usage:
   - Free tier: 50K reads/day, 20K writes/day
3. If exceeded:
   - Wait 24 hours for reset (development)
   - Upgrade to Blaze plan (production)

---

## Firestore Console Overview

### Data Structure

After setup and first sign-in, Firestore will have this structure:

```
📁 users (collection)
  📄 {userId} (document - your Google ID)
    📁 expenses (subcollection)
      📄 {expenseId}
        - id: "uuid-string"
        - userId: "your-google-id"
        - amount: 50.0
        - category: "Food & Dining"
        - description: "Lunch at McDonald's"
        - person: "Sarah" (optional)
        - date: "2026-02-14T12:00:00Z"
        - createdAt: "2026-02-14T12:00:00Z"
        - updatedAt: "2026-02-14T12:00:00Z"
    📁 categories (subcollection)
      📄 {categoryId}
        - id: "Food & Dining"
        - name: "Food & Dining"
        - colorHex: "#FF9F40"
        - iconName: "restaurant"
        - isDefault: true
        - totalSpent: 0.0
        - transactionCount: 0
        - createdAt: "2026-02-14T12:00:00Z"
        - updatedAt: "2026-02-14T12:00:00Z"
```

### Viewing Data

1. **Navigate Collections**
   - Click collection name to expand
   - Click document ID to view fields

2. **Search Documents**
   - Use search bar to find specific expenses
   - Search by field values

3. **Filter Data**
   - Use filters to query specific criteria
   - Example: `amount > 50`

4. **Export Data**
   - Click "⋮" menu → "Export"
   - Useful for backups

---

## Next Steps After Setup

1. ✅ **Test all features**
   - Add, update, delete expenses
   - Test multi-device sync
   - Test offline mode

2. ✅ **Monitor Usage**
   - Firestore → Usage tab
   - Check reads/writes count
   - Ensure under free tier limits

3. ✅ **Update Documentation**
   - Mark Phase 3 complete in MASTER_ROADMAP.md
   - Update CLAUDE.md with Firestore details
   - Update README.md with cloud sync features

4. ✅ **Deploy to Production** (when ready)
   - Build for web: `flutter build web`
   - Deploy to Firebase Hosting (optional)
   - Monitor production usage

---

## Firestore Costs (Reference)

### Free Tier (Spark Plan) - Current

- **Reads:** 50,000 per day
- **Writes:** 20,000 per day
- **Deletes:** 20,000 per day
- **Storage:** 1 GB
- **Network egress:** 10 GB/month

### Blaze Plan (Pay-as-you-go) - For Production

- **Reads:** $0.06 per 100,000 documents
- **Writes:** $0.18 per 100,000 documents
- **Deletes:** $0.02 per 100,000 documents
- **Storage:** $0.18 per GB/month
- **Network egress:** $0.12 per GB

**Estimated Cost (100 users, 10 expenses/day):**
- Writes: 1,000/day × 30 = 30,000/month = $0.05
- Reads: 10,000/day × 30 = 300,000/month = $0.18
- Storage: ~0.01 GB = $0.01
- **Total: ~$0.25/month** (very affordable!)

---

## Support & Resources

- **Firebase Documentation:** https://firebase.google.com/docs/firestore
- **Firestore Console:** https://console.firebase.google.com/project/spendwise-ai-5b1ff/firestore
- **Security Rules Guide:** https://firebase.google.com/docs/firestore/security/get-started
- **Indexes Guide:** https://firebase.google.com/docs/firestore/query-data/indexing

---

✅ **Setup Complete!** Your app now has real-time cloud sync across all devices.
