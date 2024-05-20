<script>
  // @ts-nocheck
  import AdminNavBar from "$lib/components/AdminNavBar.svelte";
  import { onMount } from "svelte";

  let users = [];
  let account_types = [];

  onMount(async () => {
    const res = await fetch("http://localhost:3000/api/users");
    users = await res.json();

    const res2 = await fetch("http://localhost:3000/api/account-types");
    account_types = await res2.json();
    console.log(account_types);
  });

  function getAccountTypeIdByName(name) {
    console.log(name);
    const account_type = account_types.find((type) => type.type_name === name);
    return account_type ? account_type.type_id : null;
  }

  const changeUserAccountType = async (user_id, new_account_type_name) => {
    const new_account_type_id = getAccountTypeIdByName(new_account_type_name);
    const res = await fetch(`http://localhost:3000/api/user/account-type`, {
      method: "PUT",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ user_id, new_account_type_id }),
    });
    const data = await res.json();
  };

  const changeUserAccountStatus = async (user_id, account_status) => {
    const res = await fetch(`http://localhost:3000/api/user/account-status`, {
      method: "PUT",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ user_id, account_status }),
    });
    const data = await res.json();
    console.log(data);
  };
</script>

<AdminNavBar />
<main>
  <h1>Users</h1>
  <table>
    <tr
      ><th>User ID</th> <th>Username</th> <th>Full Name</th> <th>Email</th><th
        >Account status</th
      ><th>Account type</th></tr
    >
    {#each users as user}
      <tr>
        <td>{user.user_id}</td>
        <td>{user.username}</td>
        <td>{user.full_name}</td>
        <td>{user.email}</td>
        <td
          ><select
            name="account_status"
            id=""
            value={user.account_status}
            on:change={(e) =>
              changeUserAccountStatus(user.user_id, e.target.value)}
          >
            <option value="active">Active</option>
            <option value="blocked">Blocked</option>
          </select></td
        >
        <td>
          <select
            name="account_type"
            id=""
            value={user.account_type_name}
            on:change={(e) =>
              changeUserAccountType(user.user_id, e.target.value)}
          >
            {#each account_types as account_type}
              <option value={account_type.type_name}
                >{account_type.type_name}</option
              >
            {/each}
          </select>
        </td>
      </tr>
    {/each}
  </table>
</main>

<style>
  h1 {
    margin: 2rem 2rem 1rem;
  }
  table {
    width: 100vw;
  }
  td {
    padding: 0.2rem 2rem;
    text-align: center;
  }
  select {
    padding: 0.5rem;
  }
</style>
