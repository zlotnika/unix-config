const axios = require('axios');

module.exports = {
  async deleteRegistryRepository(repositoryID, projectID, token, dryRun = false) {
    let tags = 'firstTime';
    while (!dryRun && tags.length > 0) {
      tags = (await axios.get(`https://gitlab.com/api/v4/projects/${projectID}/registry/repositories/${repositoryID}/tags?private_token=${token}`)).data
      tags.forEach(async (tag) => {
        console.log(`${dryRun ? 'not' : ''} deleting tag ${tag.name}`);
        if (!dryRun) {
          try {
            await axios.delete(`https://gitlab.com/api/v4/projects/${projectID}/registry/repositories/${repositoryID}/tags/${tag.name}?private_token=${token}`)
          } catch (e) {
            console.error(`e.response.status for tag.name`);
          }
        }
      })
    }

    await axios.delete(`https://gitlab.com/api/v4/projects/${projectID}/registry/repositories/${repositoryID}?private_token=${token}`)
  },
}
