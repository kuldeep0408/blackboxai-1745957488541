import React, { useState, useEffect } from 'react';

function Dashboard({ onLogout }) {
  const [posts, setPosts] = useState([]);
  const [users, setUsers] = useState([]);
  const [analytics, setAnalytics] = useState({
    totalPosts: 0,
    lostItems: 0,
    foundItems: 0,
    totalUsers: 0,
  });

  useEffect(() => {
    // TODO: Fetch posts, users, and analytics data from backend or Firebase
    // For now, using dummy data
    setPosts([
      { id: '1', itemName: 'Wallet', type: 'lost', verified: false },
      { id: '2', itemName: 'Keys', type: 'found', verified: true },
    ]);
    setUsers([
      { id: 'u1', name: 'John Doe', banned: false },
      { id: 'u2', name: 'Jane Smith', banned: true },
    ]);
    setAnalytics({
      totalPosts: 2,
      lostItems: 1,
      foundItems: 1,
      totalUsers: 2,
    });
  }, []);

  const handleVerifyPost = (postId) => {
    // TODO: Implement post verification logic
    alert(`Post ${postId} verified`);
  };

  const handleDeletePost = (postId) => {
    // TODO: Implement post deletion logic
    alert(`Post ${postId} deleted`);
  };

  const handleBanUser = (userId) => {
    // TODO: Implement user banning logic
    alert(`User ${userId} banned/unbanned`);
  };

  return (
    <div className="p-6">
      <header className="flex justify-between items-center mb-6">
        <h1 className="text-3xl font-bold">Admin Dashboard</h1>
        <button
          onClick={onLogout}
          className="bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700 transition"
        >
          Logout
        </button>
      </header>

      <section className="mb-8">
        <h2 className="text-xl font-semibold mb-4">Analytics</h2>
        <div className="grid grid-cols-4 gap-4">
          <div className="bg-blue-100 p-4 rounded shadow">
            <p className="text-2xl font-bold">{analytics.totalPosts}</p>
            <p>Total Posts</p>
          </div>
          <div className="bg-green-100 p-4 rounded shadow">
            <p className="text-2xl font-bold">{analytics.lostItems}</p>
            <p>Lost Items</p>
          </div>
          <div className="bg-yellow-100 p-4 rounded shadow">
            <p className="text-2xl font-bold">{analytics.foundItems}</p>
            <p>Found Items</p>
          </div>
          <div className="bg-purple-100 p-4 rounded shadow">
            <p className="text-2xl font-bold">{analytics.totalUsers}</p>
            <p>Total Users</p>
          </div>
        </div>
      </section>

      <section className="mb-8">
        <h2 className="text-xl font-semibold mb-4">Posts Management</h2>
        <table className="w-full border border-gray-300 rounded">
          <thead>
            <tr className="bg-gray-200">
              <th className="p-2 border border-gray-300">Item Name</th>
              <th className="p-2 border border-gray-300">Type</th>
              <th className="p-2 border border-gray-300">Verified</th>
              <th className="p-2 border border-gray-300">Actions</th>
            </tr>
          </thead>
          <tbody>
            {posts.map((post) => (
              <tr key={post.id} className="text-center">
                <td className="p-2 border border-gray-300">{post.itemName}</td>
                <td className="p-2 border border-gray-300">{post.type}</td>
                <td className="p-2 border border-gray-300">{post.verified ? 'Yes' : 'No'}</td>
                <td className="p-2 border border-gray-300 space-x-2">
                  {!post.verified && (
                    <button
                      onClick={() => handleVerifyPost(post.id)}
                      className="bg-green-500 text-white px-2 py-1 rounded hover:bg-green-600 transition"
                    >
                      Verify
                    </button>
                  )}
                  <button
                    onClick={() => handleDeletePost(post.id)}
                    className="bg-red-500 text-white px-2 py-1 rounded hover:bg-red-600 transition"
                  >
                    Delete
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </section>

      <section>
        <h2 className="text-xl font-semibold mb-4">User Management</h2>
        <table className="w-full border border-gray-300 rounded">
          <thead>
            <tr className="bg-gray-200">
              <th className="p-2 border border-gray-300">Name</th>
              <th className="p-2 border border-gray-300">Banned</th>
              <th className="p-2 border border-gray-300">Actions</th>
            </tr>
          </thead>
          <tbody>
            {users.map((user) => (
              <tr key={user.id} className="text-center">
                <td className="p-2 border border-gray-300">{user.name}</td>
                <td className="p-2 border border-gray-300">{user.banned ? 'Yes' : 'No'}</td>
                <td className="p-2 border border-gray-300">
                  <button
                    onClick={() => handleBanUser(user.id)}
                    className="bg-yellow-500 text-white px-2 py-1 rounded hover:bg-yellow-600 transition"
                  >
                    {user.banned ? 'Unban' : 'Ban'}
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </section>
    </div>
  );
}

export default Dashboard;
