# Step-by-Step Guide: How I Connected Your Project to Supabase

This is exactly how I, the AI assistant, integrated Supabase into your React application so you can do it yourself for future projects, or understand what happened behind the scenes.

---

## 🛠️ Step 1: I Configured My Internal Supabase Tooling
I have a specialized tool called the `mcp_supabase-mcp-server`. This gives me direct access to the Supabase API on your behalf. Since you were logged in, I didn't need to go to the website—I could issue commands straight from this chat interface.

1. I checked the cost using `confirm_cost` (which returned $0 for the free tier).
2. I ran `create_project` and told it to build `tic-tac-toe-multiplayer` in the `us-east-1` region.
3. Once the servers spun up (which took about a minute), I ran `get_publishable_keys` to fetch the new project's unique URL (`https://aoctclprstwwtrttqrcs.supabase.co`) and its API Key (`eyJhbG...`).

---

## 🗄️ Step 2: I Built Your Database Structure 
Instead of making you click through a dashboard, I wrote an SQL script exactly tailored to Tic-Tac-Toe and sent it using the `apply_migration` tool.

I executed the following SQL query directly onto your new Supabase database:
```sql
-- Step 1: Create the 'rooms' table to hold matches
create table rooms (
  id uuid primary key default uuid_generate_v4(),
  room_code text unique,
  host_id text not null,
  guest_id text,
  host_emoji text not null default '🦁',
  guest_emoji text,
  board jsonb not null default '["","","","","","","","",""]',
  turn text not null default 'host',
  status text not null default 'waiting',  -- waiting, playing, done
  winner text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Step 2: Create the 'chats' table
create table chats (
  id uuid primary key default uuid_generate_v4(),
  room_id uuid references rooms(id) on delete cascade not null,
  sender_id text not null,
  message text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Step 3: Turn on Realtime (WebSockets)
-- This is critical! Without this, the frontend won't get instant updates.
alter publication supabase_realtime add table rooms, chats;

-- Step 4: Turn on RLS (Row Level Security)
-- I set it so anyone playing your game is allowed to read and write to the tables.
alter table rooms enable row level security;
alter table chats enable row level security;
create policy "Allow all access to authenticated users" on rooms for all using (true);
create policy "Allow all access to authenticated users" on chats for all using (true);
```

---

## 📦 Step 3: I Installed the Packages in Your App
I opened your terminal and ran a command to install the required Supabase JavaScript library to your `package.json`:
```bash
npm install @supabase/supabase-js --save
```

---

## 🔌 Step 4: I Built the Connection File (`src/supabase.js`)
I created a brand-new file in your project called `src/supabase.js`. This file is the "bridge" between your React app and your Supabase database.

First, I fed it your URL and Key:
```javascript
import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = 'https://aoctclprstwwtrttqrcs.supabase.co';
const SUPABASE_ANON_KEY = 'YOUR_KEY_HERE';

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
```

Then, I wrote helper functions to make the database easy to use inside your React components. For example, creating a room looks like this inside `supabase.js`:
```javascript
export async function createRoom(hostId, hostEmoji) {
    const { data, error } = await supabase
        .from('rooms')
        .insert([{ host_id: hostId, host_emoji: hostEmoji }])
        .select()
        .single();
    if (error) throw error;
    return data;
}
```

---

## 📡 Step 5: I Wired Up Real-Time Subscriptions
Because Tic-Tac-Toe is a fast multiplayer game, we can't wait for HTTP requests. We need WebSockets. I added a `subscribeRoom` function in `src/supabase.js`:

```javascript
export function subscribeRoom(roomId, onUpdate) {
    return supabase
        .channel(`room:${roomId}`)
        .on(
            'postgres_changes',
            { event: 'UPDATE', schema: 'public', table: 'rooms', filter: `id=eq.${roomId}` },
            (payload) => {
                onUpdate(payload.new); // This updates the React state instantly!
            }
        )
        .subscribe();
}
```

---

## 🎮 Step 6: I Hooked It Up to the User Interface
Finally, I completely rewrote `OnlineMatchPage.jsx` and `AuthPage.jsx` to use these new functions instead of dummy data.

**Example of how I changed a button click:**
Instead of just running `setBoard()` when someone clicks a Tic-Tac-Toe square, I made it update the **database**:
```javascript
const handleCellClick = async (index) => {
    // 1. Copy the board
    const newBoard = [...board];
    newBoard[index] = mySymbol; // 'X' or 'O'

    // 2. Change turns locally
    const nextTurn = role === 'host' ? 'guest' : 'host';

    // 3. ✨ Tell Supabase! ✨
    await supabase
        .from('rooms')
        .update({ board: newBoard, turn: nextTurn })
        .eq('id', room.id);
};
```
Because of **Step 5** (the subscription), as soon as the `update()` command hits the database, Supabase instantly blasts the new board out to *both* players' screens simultaneously!
